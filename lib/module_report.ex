defmodule Doctor.ModuleReport do
  @moduledoc """
  This module exposes a struct which encapsulates all the results for a doctor report. Whether
  the module has a moduledoc, what the doc coverage is, the number of author defined functions,
  and so on.
  """

  alias __MODULE__
  alias Doctor.{ModuleInformation, Config}

  @type t :: %ModuleReport{
          doc_coverage: Decimal.t(),
          spec_coverage: Decimal.t(),
          file: String.t(),
          module: String.t(),
          functions: integer(),
          missed_docs: integer(),
          missed_specs: integer(),
          has_module_doc: boolean(),
          has_struct_type_spec: atom() | boolean(),
          properties: Keyword.t()
        }

  defstruct ~w(
    doc_coverage
    spec_coverage
    file
    module
    functions
    missed_docs
    missed_specs
    has_module_doc
    has_struct_type_spec
    properties
  )a

  @doc """
  Given a ModuleInformation struct with the necessary fields completed,
  build the report.
  """
  def build(%ModuleInformation{} = module_info, %Config{} = config) do
    %ModuleReport{
      doc_coverage: calculate_doc_coverage(module_info),
      spec_coverage: calculate_spec_coverage(module_info),
      file: module_info.file_relative_path,
      module: generate_module_name(module_info.module),
      functions: length(module_info.user_defined_functions),
      missed_docs: calculate_missed_docs(module_info),
      missed_specs: calculate_missed_specs(module_info),
      has_module_doc: has_module_doc?(module_info, config),
      has_struct_type_spec: module_info.struct_type_spec,
      properties: module_info.properties
    }
  end

  defp generate_module_name(module) do
    module
    |> Module.split()
    |> Enum.join(".")
  end

  defp calculate_missed_docs(module_info) do
    function_arity_list =
      Enum.map(module_info.user_defined_functions, fn {function, arity, _impl} ->
        {function, arity}
      end)

    docs_arity_list = Enum.map(module_info.docs, fn doc -> {doc.name, doc.arity} end)

    functions_not_in_docs =
      Enum.count(function_arity_list, fn fun ->
        fun not in docs_arity_list
      end)

    functions_without_docs =
      Enum.count(module_info.docs, fn doc ->
        {doc.name, doc.arity} in function_arity_list and doc.doc == :none
      end)

    functions_not_in_docs + functions_without_docs
  end

  defp calculate_doc_coverage(module_info) do
    total = length(module_info.user_defined_functions)
    missed = calculate_missed_docs(module_info)

    if total > 0 do
      (total - missed)
      |> Decimal.div(total)
      |> Decimal.mult(100)
    else
      nil
    end
  end

  defp calculate_missed_specs(module_info) do
    function_specs =
      module_info.specs
      |> Enum.map(fn spec ->
        {spec.name, spec.arity}
      end)

    Enum.count(module_info.user_defined_functions, fn {function, arity, impl} ->
      cond do
        {function, arity} in function_specs ->
          false

        is_boolean(impl) and impl and module_info.behaviours != [] ->
          false

        is_atom(impl) and impl != :none and module_info.behaviours != [] ->
          false

        true ->
          true
      end
    end)
  end

  defp calculate_spec_coverage(module_info) do
    total = length(module_info.user_defined_functions)
    missed = calculate_missed_specs(module_info)

    if total > 0 do
      (total - missed)
      |> Decimal.div(total)
      |> Decimal.mult(100)
    else
      nil
    end
  end

  defp has_module_doc?(module_info, config) do
    failed_doc_cases = [:none, %{}]

    failed_doc_cases =
      case config.include_hidden_doc do
        true -> failed_doc_cases ++ [:hidden]
        _ -> failed_doc_cases
      end

    module_info.module_doc not in failed_doc_cases
  end
end
