defmodule Mix.Tasks.Doctor do
  use Mix.Task

  alias Doctor.Reporters.{Full, Summary}
  alias Mix.Shell.IO

  @shortdoc "Documentation coverage report"
  @recursive true

  @config_file ".doctor.exs"
  @defaults %{
    moduledoc_required: true,
    typespec_required: false,
    min_overall_coverage: 60,
    min_module_coverage: 50,
    ignore_modules: [],
    ignore_paths: [],
    reporter: Full
  }

  def run(args) do
    @config_file
    |> load_config_file()
    |> merge_defaults()
    |> merge_cli_args(args)
    |> Doctor.CLI.report()
  end

  defp load_config_file(file) do
    if File.exists?(file) do
      IO.info("Doctor file found. Loading configuration.")

      {config, _bindings} = Code.eval_file(file)

      config
    else
      IO.info("Doctor file not found. Using defaults.")

      %{}
    end
  end

  defp merge_defaults(config) do
    Map.merge(@defaults, config)
  end

  defp merge_cli_args(config, args) do
    options =
      args
      |> Enum.reduce(%{}, fn
        "--full", acc ->
          Map.merge(acc, %{reporter: Full})

        "--summary", acc ->
          Map.merge(acc, %{reporter: Summary})

        _, acc ->
          acc
      end)

    Map.merge(config, options)
  end
end
