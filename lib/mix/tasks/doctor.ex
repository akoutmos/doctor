defmodule Mix.Tasks.Doctor do
  @moduledoc false

  use Mix.Task

  alias Doctor.{CLI, Config}
  alias Doctor.Reporters.{Full, Short, Summary}

  @shortdoc "Documentation coverage report"
  @recursive true
  @umbrella_accumulator Doctor.Umbrella

  @doc """
  This Mix task generates a Doctor report of the project.
  """
  def run(args) do
    config =
      Config.config_file()
      |> load_config_file()
      |> merge_defaults()
      |> merge_cli_args(args)

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

  defp load_config_file(file) do
    # If we are performing this operation on an umbrella app then look to
    # the project root for the config file
    file =
      if Mix.Task.recursing?() do
        Path.join(["..", "..", file])
      else
        file
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

  defp merge_defaults(config) do
    Map.merge(Config.config_defaults(), config)
  end

  defp merge_cli_args(config, args) do
    options =
      args
      |> Enum.reduce(%{}, fn
        "--full", acc ->
          Map.merge(acc, %{reporter: Full})

        "--short", acc ->
          Map.merge(acc, %{reporter: Short})

        "--summary", acc ->
          Map.merge(acc, %{reporter: Summary})

        "--raise", acc ->
          Map.merge(acc, %{raise: true})

        "--umbrella", acc ->
          Map.merge(acc, %{umbrella: true})

        _, acc ->
          acc
      end)

    Map.merge(config, options)
  end
end
