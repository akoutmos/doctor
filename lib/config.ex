defmodule Doctor.Config do
  @moduledoc """
  This module defines a struct which houses all the
  configuration data for Doctor.
  """

  @config_file ".doctor.exs"

  alias __MODULE__

  @type t :: %Config{
          ignore_modules: [Regex.t() | String.t()],
          ignore_paths: [Regex.t() | module()],
          min_module_doc_coverage: integer() | float(),
          min_module_spec_coverage: integer() | float(),
          min_overall_doc_coverage: integer() | float(),
          min_overall_spec_coverage: integer() | float(),
          moduledoc_required: boolean(),
          exception_moduledoc_required: boolean(),
          raise: boolean(),
          reporter: module(),
          struct_type_spec_required: boolean(),
          umbrella: boolean(),
          include_hidden_doc: boolean(),
          failed: false
        }

  defstruct ignore_modules: [],
            ignore_paths: [],
            min_module_doc_coverage: 40,
            min_module_spec_coverage: 0,
            min_overall_doc_coverage: 50,
            min_overall_spec_coverage: 0,
            moduledoc_required: true,
            exception_moduledoc_required: true,
            raise: false,
            reporter: Doctor.Reporters.Full,
            struct_type_spec_required: true,
            umbrella: false,
            include_hidden_doc: false,
            failed: false

  @doc """
  Get the configuration defaults as a Config struct
  """
  def config_defaults, do: %Config{}

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
