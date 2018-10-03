defmodule Doctor.Config do
  # TODO: Convert this to a struct

  @default_config %{
    moduledoc_required: true,
    typespec_required: false,
    min_overall_coverage: 60,
    min_module_coverage: 50,
    ignore_modules: [],
    ignore_paths: [],
    reporter: Doctor.Reporters.Full
  }

  @config_file ".doctor.exs"

  def config_defaults_as_map, do: @default_config

  def config_defaults_as_string do
    config = quote do: unquote(@default_config)

    config
    |> Macro.to_string()
    |> Code.format_string!()
  end

  def config_file, do: @config_file
end
