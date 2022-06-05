defmodule Mix.Tasks.Doctor.Explain do
  @moduledoc """
  Figuring out why a particular module failed Doctor validation can sometimes
  be a bit difficult when the relevant information is embedded within a table with
  other validation results.

  The `mix doctor.explain` command has only a single required argument. That argument
  is the name of the module that you wish to get a detailed report of. For example you
  could run the following from the terminal:

  ```
  $ mix doctor.explain MyApp.Some.Module
  ```

  To generate a report like this:

  ```
  Doctor file found. Loading configuration.

  Function            @doc  @spec
  -------------------------------
  generate_report/2   ✗     ✗

  Module Results:
    Doc Coverage:    0.0%  --> Your config has a 'min_module_doc_coverage' value of 80
    Spec Coverage:   0.0%
    Has Module Doc:  ✓
    Has Struct Spec: N/A
  ```

  In addition, the following CLI flags are supported (similarly to the `mix doctor`
  command):

  ```
  --config-file  Provide a relative or absolute path to a `.doctor.exs`
                 file to use during the execution of the mix command.

  --raise        If any of your modules fails Doctor validation, then
                 raise an error and return a non-zero exit status.
  ```

  To use these command line args you would do something like so:

  ```
  $ mix doctor.explain --raise --config_file /some/path/to/some/.doctor.exs MyApp.Some.Module
  ```

  Note that `mix doctor.explain` takes a module name instead of a file path since you can
  define multiple modules in a single file.
  """

  use Mix.Task

  alias Doctor.{CLI, Config}

  @shortdoc "Debug why a particular module is failing validation"
  @recursive true
  @umbrella_accumulator Doctor.Umbrella

  @impl true
  def run(args) do
    default_config_opts = Config.config_defaults()
    {cli_arg_opts, args} = parse_cli_args(args)
    config_file_opts = load_config_file(cli_arg_opts)

    # Aggregate all of the various options sources
    # Precedence order is:
    # default < config file < cli args
    config =
      default_config_opts
      |> Map.merge(config_file_opts)
      |> Map.merge(cli_arg_opts)

    # Get the module name from args
    module_name =
      case args do
        [module] ->
          module

        _error ->
          raise "Invalid Argument: mix doctor.explain takes only a single module name as an argument"
      end

    if config.umbrella do
      run_umbrella(module_name, config)
    else
      run_default(module_name, config)
    end
  end

  defp run_umbrella(module_name, config) do
    acc_pid =
      case Process.whereis(@umbrella_accumulator) do
        nil -> init_umbrella_acc(module_name, config)
        pid -> pid
      end

    case CLI.generate_single_module_report(module_name, config) do
      :not_found ->
        :ok

      result ->
        Agent.update(acc_pid, fn %{result: acc_result} ->
          %{found: true, result: acc_result && result}
        end)
    end

    :ok
  end

  defp run_default(module_name, config) do
    case CLI.generate_single_module_report(module_name, config) do
      :not_found ->
        raise "Could not find module #{inspect(module_name)} in application"

      result ->
        unless result do
          System.at_exit(fn _ ->
            exit({:shutdown, 1})
          end)

          if config.raise do
            Mix.raise("Doctor validation has failed and raised an error")
          end
        end
    end

    :ok
  end

  defp init_umbrella_acc(module_name, config) do
    {:ok, pid} = Agent.start_link(fn -> %{found: false, result: true} end, name: @umbrella_accumulator)

    System.at_exit(fn _ ->
      acc = Agent.get(pid, & &1)
      Agent.stop(pid)
      report_umbrella_result(acc, module_name, config)
    end)

    pid
  end

  defp report_umbrella_result(%{found: false}, module_name, _config) do
    raise "Could not find module #{inspect(module_name)} in application"
  end

  defp report_umbrella_result(%{result: true}, _module_name, _config), do: :ok

  defp report_umbrella_result(_acc, _module_name, config) do
    if config.raise do
      Mix.raise("Doctor validation has failed and raised an error")
    end

    exit({:shutdown, 1})
  end

  defp load_config_file(%{config_file_path: file_path} = _cli_args) do
    full_path = Path.expand(file_path)

    if File.exists?(full_path) do
      Mix.shell().info("Doctor file found. Loading configuration.")

      {config, _bindings} = Code.eval_file(full_path)

      config
    else
      Mix.shell().error("Doctor file not found at path \"#{full_path}\". Using defaults.")

      %{}
    end
  end

  defp load_config_file(_) do
    # If we are performing this operation on an umbrella app then look to
    # the project root for the config file
    file =
      if Mix.Task.recursing?() do
        Path.join(["..", "..", Config.config_file()])
      else
        Config.config_file()
      end

    if File.exists?(file) do
      Mix.shell().info("Doctor file found. Loading configuration.")

      {config, _bindings} = Code.eval_file(file)

      config
    else
      Mix.shell().info("Doctor file not found. Using defaults.")

      %{}
    end
  end

  defp parse_cli_args(args) do
    {parsed_args, args, _invalid} =
      OptionParser.parse(args,
        strict: [
          raise: :boolean,
          config_file: :string
        ]
      )

    parsed_args =
      parsed_args
      |> Enum.reduce(%{}, fn
        {:raise, true}, acc -> Map.merge(acc, %{raise: true})
        {:config_file, file_path}, acc -> Map.merge(acc, %{config_file_path: file_path})
        _unexpected_arg, acc -> acc
      end)

    {parsed_args, args}
  end
end
