defmodule Doctor.ModuleReport do
  @moduledoc """
  This module exposes a struct which encapsulates all the results for a doctor report. Whether
  the module has a moduledoc, what the doc coverage is, the number of author defined functions,
  and so on.
  """

  alias __MODULE__
  alias Doctor.ModuleInformation

  defstruct ~w(doc_coverage spec_coverage file functions missed_docs missed_specs has_module_doc)a

  @doc """
  Given a ModuleInformation struct with the necessary fields completed,
  build the report.
  """
  def build(%ModuleInformation{} = module_info) do
    %ModuleReport{
      doc_coverage: calculate_doc_coverage(module_info),
      spec_coverage: calculate_spec_coverage(module_info),
      file: module_info.file_relative_path,
      functions: length(module_info.user_defined_functions),
      missed_docs: calculate_missed_docs(module_info),
      missed_specs: calculate_missed_specs(module_info),
      has_module_doc: has_module_doc?(module_info)
    }
  end

  defp calculate_missed_docs(module_info) do
    Enum.count(module_info.docs, fn doc ->
      {doc.name, doc.arity} in module_info.user_defined_functions and doc.doc == :none
    end)
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
    Enum.count(module_info.user_defined_functions, fn function ->
      function not in module_info.specs
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

  defp has_module_doc?(module_info) do
    if module_info.module_doc == :none do
      false
    else
      true
    end
  end
end
