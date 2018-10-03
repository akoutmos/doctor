defmodule Doctor.ModuleInformation do
  @moduledoc """
  """

  alias __MODULE__
  alias Doctor.Docs

  defstruct ~w(module file_full_path file_relative_path file_ast docs_version module_doc metadata docs user_defined_functions type_specs)a

  @doc """
  Breaks down the docs format entry returned from Code.fetch_docs(MODULE)
  """
  def build({docs_version, _annotation, _language, _format, module_doc, metadata, docs}, module) do
    %ModuleInformation{
      module: module,
      file_full_path: get_full_file_path(module),
      file_relative_path: get_relative_file_path(module),
      file_ast: nil,
      docs_version: docs_version,
      module_doc: module_doc,
      metadata: metadata,
      docs: Enum.map(docs, &Docs.build/1),
      user_defined_functions: nil,
      type_specs: nil
    }
  end

  def load_file_ast(%ModuleInformation{} = module_info) do
    ast =
      module_info.file_full_path
      |> File.read!()
      |> Code.string_to_quoted!()

    %{module_info | file_ast: ast}
  end

  def load_user_defined_functions(%ModuleInformation{} = module_info) do
    {_ast, functions} =
      module_info.file_ast
      |> Macro.prewalk([], fn
        {:def, _def_line, [{function_name, _body_line, _body}, _]} = tuple, acc
        when function_name != :when ->
          {tuple, [function_name | acc]}

        tuple, acc ->
          {tuple, acc}
      end)

    %{module_info | user_defined_functions: functions}
  end

  defp get_full_file_path(module) do
    module.module_info()
    |> Keyword.get(:compile)
    |> Keyword.get(:source)
    |> to_string()
  end

  defp get_relative_file_path(module) do
    module
    |> get_full_file_path()
    |> Path.relative_to(File.cwd!())
  end
end
