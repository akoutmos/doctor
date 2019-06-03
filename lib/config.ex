defmodule Doctor.Config do
  @moduledoc """
  This module defines a struct which houses all the
  configuration data for Doctor.
  """

  @config_file ".doctor.exs"

  alias __MODULE__

  defstruct moduledoc_required: true,
            min_overall_doc_coverage: 50,
            min_overall_spec_coverage: 0,
            min_module_doc_coverage: 40,
            min_module_spec_coverage: 0,
            ignore_modules: [],
            ignore_paths: [],
            reporter: Doctor.Reporters.Full

  @doc """
  Get the configuration defaults as a Config struct
  """
  def config_defaults_as_map, do: %Config{}

  @doc """
  Get the configuration defaults as a string
  """
  def config_defaults_as_string do
    config = quote do: unquote(%Config{})

    config
    |> Macro.to_string()
    |> Code.format_string!()
  end

  @doc """
  Get the configuration file name
  """
  def config_file, do: @config_file
end
