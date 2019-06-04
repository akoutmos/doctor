defmodule Doctor.ModuleInformation do
  @moduledoc """
  This module defines a struct which houses all the
  documentation data for an entire module.
  """

  alias __MODULE__
  alias Doctor.{Docs, Specs}

  defstruct ~w(module file_full_path file_relative_path file_ast docs_version module_doc metadata docs specs user_defined_functions)a

  @doc """
  Breaks down the docs format entry returned from Code.fetch_docs(MODULE)
  """
  def build({docs_version, _annotation, _language, _format, module_doc, metadata, docs}, module) do
    {:ok, module_specs} = Code.Typespec.fetch_specs(module)

    %ModuleInformation{
      module: module,
      file_full_path: get_full_file_path(module),
      file_relative_path: get_relative_file_path(module),
      file_ast: nil,
      docs_version: docs_version,
      module_doc: module_doc,
      metadata: metadata,
      docs: Enum.map(docs, &Docs.build/1),
      specs: Enum.map(module_specs, &Specs.build/1),
      user_defined_functions: nil
    }
  end

  @doc """
  Given the provided module, read the file from which the module was generated and
  convert the file to an AST.
  """
  def load_file_ast(%ModuleInformation{} = module_info) do
    ast =
      module_info.file_full_path
      |> File.read!()
      |> Code.string_to_quoted!()

    %{module_info | file_ast: ast}
  end

  @doc """
  Given a ModuleInformation struct with the AST loaded, fetch all of the author defined functions
  """
  def load_user_defined_functions(%ModuleInformation{} = module_info) do
    {_ast, modules} = Macro.prewalk(module_info.file_ast, %{}, &parse_ast_node_for_defmodules/2)

    {_ast, functions} =
      modules
      |> Map.get(module_info.module)
      |> Macro.prewalk([], &parse_ast_node_for_def/2)

    %{module_info | user_defined_functions: Enum.uniq(functions)}
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

  defp parse_ast_node_for_def(
         {:def, _def_line,
          [{:when, _line_when, [{function_name, _function_line, args}, _guard]}, _do_block]} =
           ast,
         acc
       ) do
    {ast, [{function_name, get_function_arity(args)} | acc]}
  end

  defp parse_ast_node_for_def(
         {:def, _def_line, [{function_name, _function_line, args}, _do_block]} = ast,
         acc
       ) do
    {ast, [{function_name, get_function_arity(args)} | acc]}
  end

  defp parse_ast_node_for_def(
         {:def, _def_line, [{function_name, _function_line, args}]} = ast,
         acc
       ) do
    {ast, [{function_name, get_function_arity(args)} | acc]}
  end

  defp parse_ast_node_for_def(ast, acc) do
    {ast, acc}
  end

  defp parse_ast_node_for_defmodules(
         {definition, _defmodule_line, [{:__aliases__, _line_num, module}, _do_block]} = ast,
         acc
       )
       when definition in [:defmodule, :defprotocol] do
    module_in_ast = Module.concat(module)
    {ast, Map.put(acc, module_in_ast, ast)}
  end

  defp parse_ast_node_for_defmodules(ast, acc) do
    {ast, acc}
  end

  defp get_function_arity(nil), do: 0
  defp get_function_arity(args), do: length(args)
end
