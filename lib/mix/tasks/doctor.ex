defmodule Mix.Tasks.Doctor do
  @moduledoc """
  Doctor is a command line utility that can be used to ensure that your project
  documentation remains healthy. For more in depth documentation on Doctor or to
  file bug/feature requests, please check out https://github.com/akoutmos/doctor.

  The `mix doctor` command supports the following CLI flags (all of these options
  and more are also configurable from your `.doctor.exs` file). The following CLI
  flags are supported:

  ```
  --config_file  Provide a relative or absolute path to a `.doctor.exs`
                 file to use during the execution of the mix command.

  --full         When generating a Doctor report of your project, use
                 the Doctor.Reporters.Full reporter.

  --short        When generating a Doctor report of your project, use
                 the Doctor.Reporters.Short reporter.

  --summary      When generating a Doctor report of your project, use
                 the Doctor.Reporters.Summary reporter.

  --raise        If any of your modules fails Doctor validation, then
                 raise an error and return a non-zero exit status.

  --failed       If set, only the failed modules will be reported. Works with
                 --full and --short options.

  --umbrella     By default, in an umbrella project, each app will be
                 evaluated independently against the specified thresholds
                 in your .doctor.exs file. This flag changes that behavior
                 by aggregating the results of all your umbrella apps,
                 and then comparing those results to the configured
                 thresholds.
  ```
  """

  use Mix.Task
  alias Doctor.{CLI, Config}
  alias Doctor.Reporters.{Full, Short, Summary}

  @shortdoc "Documentation coverage report"
  @recursive true
  @umbrella_accumulator Doctor.Umbrella

  # For escript entry
  def main(args) do
    run(args)
  end

  @impl true
  def run(args) do
    cli_arg_opts = parse_cli_args(args)
    config_file_opts = load_config_file(cli_arg_opts)

    # Aggregate all of the various options sources
    # Precedence order is:
    # default < config file < cli args
    config =
      config_file_opts
      |> Map.merge(cli_arg_opts)
      |> Config.new()

    if config.umbrella do
      run_umbrella(config)
    else
      run_default(config)
    end
  end

  defp run_umbrella(config) do
    module_report_list = CLI.generate_module_report_list(config)

    acc_pid =
      case Process.whereis(@umbrella_accumulator) do
        nil -> init_umbrella_acc(config)
        pid -> pid
      end

    Agent.update(acc_pid, fn acc ->
      acc ++ module_report_list
    end)

    :ok
  end

  defp run_default(config) do
    result =
      config
      |> CLI.generate_module_report_list()
      |> CLI.process_module_report_list(config)

    unless result do
      System.at_exit(fn _ ->
        exit({:shutdown, 1})
      end)

      if config.raise do
        Mix.raise("Doctor validation has failed and raised an error")
      end
    end

    :ok
  end

  defp init_umbrella_acc(config) do
    {:ok, pid} = Agent.start_link(fn -> [] end, name: @umbrella_accumulator)

    System.at_exit(fn _ ->
      module_report_list = Agent.get(pid, & &1)
      Agent.stop(pid)
      result = CLI.process_module_report_list(module_report_list, config)

      unless result do
        if config.raise do
          Mix.raise("Doctor validation has failed and raised an error")
        end

        exit({:shutdown, 1})
      end
    end)

    pid
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
          failed: :boolean,
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
      {:failed, true}, acc -> Map.merge(acc, %{failed: true})
      {:umbrella, true}, acc -> Map.merge(acc, %{umbrella: true})
      {:config_file, file_path}, acc -> Map.merge(acc, %{config_file_path: file_path})
      _unexpected_arg, acc -> acc
    end)
  end
end
