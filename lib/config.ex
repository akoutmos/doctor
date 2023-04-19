defmodule Doctor.Config do
  @moduledoc """
  This module defines a struct which houses all the
  configuration data for Doctor.
  """

  @config_file ".doctor.exs"

  require Logger
  alias __MODULE__

  @typedoc """
  * `:min_module_doc_coverage` - Minimum ratio of @doc vs public functions
    per module.
  * `:min_overall_doc_coverage` - Minimum ratio of @doc vs public functions
    across the codebase.
  * `:min_overall_moduledoc_coverage` - Minimum ratio of @moduledoc to modules
    across the codebase.
  * `:moduledoc_required` - If true, `:min_overall_moduledoc_coverage` is
    automatically set to 100%. Deprecated.
  """
  @type t :: %Config{
          ignore_modules: [Regex.t() | String.t()],
          ignore_paths: [Regex.t() | module()],
          min_module_doc_coverage: integer() | float(),
          min_module_spec_coverage: integer() | float(),
          min_overall_doc_coverage: integer() | float(),
          min_overall_moduledoc_coverage: integer() | float(),
          min_overall_spec_coverage: integer() | float(),
          moduledoc_required: boolean(),
          exception_moduledoc_required: boolean() | nil,
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
            min_overall_moduledoc_coverage: 100,
            min_overall_spec_coverage: 0,
            moduledoc_required: nil,
            exception_moduledoc_required: true,
            raise: false,
            reporter: Doctor.Reporters.Full,
            struct_type_spec_required: true,
            umbrella: false,
            include_hidden_doc: false,
            failed: false

  @doc """
  Create a new Config struct from a map, keyword list or preexisting Config.
  """
  @spec new(keyword | map) :: Config.t()
  def new(attrs \\ %{}) do
    config =
      case attrs do
        %Config{} = c -> c
        map_or_keyword -> struct(Config, map_or_keyword)
      end

    interpret_moduledoc_required(config)
  end

  @doc """
  Returns true if a specific module should fail validation if it lacks a
  moduledoc."
  """
  @spec moduledoc_required?(t) :: boolean
  def moduledoc_required?(%{min_overall_moduledoc_coverage: 100}), do: true
  def moduledoc_required?(_), do: false

  @doc """
  Get the configuration defaults as a string
  """
  def config_defaults_as_string do
    config = quote do: unquote(%Config{})

    iodata = config |> Macro.to_string() |> Code.format_string!()

    # Drop the `:moduledoc_required` option in favor of `:min_overall_moduledoc_coverage`.
    idx = Enum.find_index(iodata, &(&1 == "moduledoc_required:"))
    Enum.slice(iodata, 0..(idx - 1)) ++ Enum.slice(iodata, (idx + 6)..-1)
  end

  @doc """
  Get the configuration file name
  """
  def config_file, do: @config_file

  # If `:moduledoc_required` is defined in the config, warn the user about the
  # deprecation. In a future version, the struct key and associated
  # backwards-compatibility code could be removed.
  @spec interpret_moduledoc_required(Config.t()) :: Config.t()
  defp interpret_moduledoc_required(%{moduledoc_required: nil} = config) do
    config
  end

  defp interpret_moduledoc_required(%{moduledoc_required: true} = config) do
    warn_deprecation(true, 100)
    %{config | min_overall_moduledoc_coverage: 100}
  end

  defp interpret_moduledoc_required(%{moduledoc_required: false} = config) do
    warn_deprecation(false, 0)
    %{config | min_overall_moduledoc_coverage: 0}
  end

  defp warn_deprecation(_bool, val) do
    Logger.warn("""
    :moduledoc_required in #{Config.config_file()} is a deprecated option. \
    Now running with the equivalent :min_overall_moduledoc_coverage #{val} \
    but you should replace the deprecated option with the new one to avoid \
    this warning.\
    """)
  end
end
