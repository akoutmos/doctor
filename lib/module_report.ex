defmodule Doctor.ModuleReport do
  alias Mix.Shell.IO

  alias __MODULE__
  alias Doctor.ModuleInformation

  defstruct ~w(coverage file functions missed module_doc)a

  def build(%ModuleInformation{} = module_info) do
    %ModuleReport{
      coverage: calculate_coverage(module_info),
      file: module_info.file_relative_path,
      functions: length(module_info.user_defined_functions),
      missed: calculate_missed_functions(module_info),
      module_doc: has_module_doc?(module_info)
    }
  end

  defp calculate_missed_functions(module_info) do
    Enum.count(module_info.docs, fn doc ->
      doc.name in module_info.user_defined_functions and doc.doc == :none
    end)
  end

  defp calculate_coverage(module_info) do
    total = length(module_info.user_defined_functions)
    missed = calculate_missed_functions(module_info)

    if total > 0 do
      (total - missed) / total * 100
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
