defmodule Mix.Tasks.Doctor.Explain do
  @moduledoc """
  Figuring out why a particular module failed Doctor validation can sometimes
  be a bit difficult when the relevant information is embedded within a table with
  other validation results. This Mix command takes as its only argument the name of
  a module and will provide a detailed report as to whether the module passed
  validation or what exactly caused it to fail validation. Note that `mix doctor.explain`
  takes a module name instead of a file path since you can define multiple modules
  in a single file.

  To use this Mix command do the following from the terminal:

  ```
  $ mix doctor.explain MyApp.Some.Module
  ```

  To generate a report like the following:

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
  """

  use Mix.Task

  alias Doctor.{CLI, Config}
  alias Doctor.Reporters.{Full, Short, Summary}

  @shortdoc "Documentation coverage report"
  @recursive true
  @umbrella_accumulator Doctor.Umbrella

  @impl true
  def run(args) do
    default_config_opts = Config.config_defaults()
    cli_arg_opts = parse_cli_args(args)
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
      case System.argv() do
        [_mix_command, module] ->
          module

        error ->
          raise "Invalid Argument: mix doctor.explain takes only a single module name as an argument"
      end

    result = CLI.generate_single_module_report(module_name, config)

    unless result do
      System.at_exit(fn _ ->
        exit({:shutdown, 1})
      end)
    end

    :ok
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
    {parsed_args, _args, _invalid} =
      OptionParser.parse(args,
        strict: [
          full: :boolean,
          short: :boolean,
          summary: :boolean,
          raise: :boolean,
          umbrella: :boolean,
          config_file: :string
        ]
      )

    parsed_args
    |> Enum.reduce(%{}, fn
      {:full, true}, acc -> Map.merge(acc, %{reporter: Full})
      {:short, true}, acc -> Map.merge(acc, %{reporter: Short})
      {:summary, true}, acc -> Map.merge(acc, %{reporter: Summary})
      {:raise, true}, acc -> Map.merge(acc, %{raise: true})
      {:umbrella, true}, acc -> Map.merge(acc, %{umbrella: true})
      {:config_file, file_path}, acc -> Map.merge(acc, %{config_file_path: file_path})
      _unexpected_arg, acc -> acc
    end)
  end
end
