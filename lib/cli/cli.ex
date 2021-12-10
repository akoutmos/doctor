defmodule Doctor.CLI do
  @moduledoc """
  Provides the various CLI task entry points and CLI arg parsing.
  """

  alias Mix.Project
  alias Doctor.{ModuleInformation, ModuleReport, ReportUtils}
  alias Doctor.Reporters.ModuleExplain

  @doc """
  Given the CLI arguments, run the report on the project,
  """
  def generate_module_report_list(args) do
    # Using the project's app name, fetch all the modules associated with the app
    Project.config()
    |> Keyword.get(:app)
    |> get_application_modules()

    # Fetch the module information from the list of application modules
    |> Enum.map(&generate_module_entry/1)

    # Filter out any files/modules that were specified in the config
    |> Enum.reject(fn module_info -> filter_ignore_modules(module_info.module, args.ignore_modules) end)
    |> Enum.reject(fn module_info -> filter_ignore_paths(module_info.file_relative_path, args.ignore_paths) end)

    # Asynchronously get the user defined functions from the modules
    |> Enum.map(&async_fetch_user_defined_functions/1)
    |> Enum.map(&Task.await(&1, 15_000))

    # Build report struct for each module
    |> Enum.sort(&(&1.file_relative_path < &2.file_relative_path))
    |> Enum.map(fn module -> ModuleReport.build(module, args) end)
  end

  @doc """
  Generate a report for a single project module.
  """
  def generate_single_module_report(module_name, args) do
    Project.config()
    |> Keyword.get(:app)
    |> get_application_modules()
    |> Enum.find(:not_found, fn module ->
      Atom.to_string(module) == "Elixir.#{module_name}"
    end)
    |> case do
      :not_found ->
        raise "Could not find module #{inspect(module_name)} in application"

      module ->
        module
        |> generate_module_entry()
        |> async_fetch_user_defined_functions()
        |> Task.await(15_000)
    end
    |> ModuleExplain.generate_report(args)
  end

  @doc """
  Given a list of individual module reports, process each item in the
  list with the configured reporter and return a pass or fail boolean
  """
  def process_module_report_list(module_report_list, args) do
    # Invoke the configured module reporter and return whether Doctor validation passed/failed
    args.reporter.generate_report(module_report_list, args)
    ReportUtils.doctor_report_passed?(module_report_list, args)
  end

  defp generate_module_entry(module) do
    module
    |> Code.fetch_docs()
    |> ModuleInformation.build(module)
  end

  defp async_fetch_user_defined_functions(%ModuleInformation{} = module_info) do
    Task.async(fn ->
      module_info
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
    end)
  end

  defp get_application_modules(application) do
    # Compile and load the application
    Mix.Task.run("compile")
    Application.load(application)

    # Get all the modules in the application
    {:ok, modules} = :application.get_key(application, :modules)

    modules
  end

  defp filter_ignore_paths(file_relative_path, ignore_paths) do
    ignore_paths
    |> Enum.reduce_while(false, fn pattern, _acc ->
      compare_ignore_path(file_relative_path, pattern)
    end)
  end

  defp compare_ignore_path(file_relative_path, %Regex{} = ignore_pattern) do
    if Regex.match?(ignore_pattern, file_relative_path) do
      {:halt, true}
    else
      {:cont, false}
    end
  end

  defp compare_ignore_path(file_relative_path, ignore_string) when is_bitstring(ignore_string) do
    if file_relative_path == ignore_string do
      {:halt, true}
    else
      {:cont, false}
    end
  end

  defp compare_ignore_path(_, ignore_value),
    do: raise("Encountered invalid ignore_paths entry: #{inspect(ignore_value)}")

  defp filter_ignore_modules(module, ignore_modules) do
    ignore_modules
    |> Enum.reduce_while(false, fn pattern, _acc ->
      compare_ignore_module(module, pattern)
    end)
  end

  defp compare_ignore_module(module, %Regex{} = ignore_pattern) do
    module_as_string =
      module
      |> Atom.to_string()
      |> String.trim_leading("Elixir.")

    if Regex.match?(ignore_pattern, module_as_string) do
      {:halt, true}
    else
      {:cont, false}
    end
  end

  defp compare_ignore_module(module, ignore_module) when is_atom(ignore_module) do
    if module == ignore_module do
      {:halt, true}
    else
      {:cont, false}
    end
  end

  defp compare_ignore_module(_, ignore_value),
    do: raise("Encountered invalid ignore_module entry: #{inspect(ignore_value)}")
end
