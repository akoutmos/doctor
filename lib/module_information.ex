defmodule Doctor.ModuleInformation do
  @moduledoc """
  This module defines a struct which houses all the
  documentation data for an entire module.
  """

  alias __MODULE__
  alias Doctor.{Docs, Specs}

  @type t :: %ModuleInformation{
          module: module(),
          behaviours: [module()],
          file_full_path: String.t(),
          file_relative_path: String.t(),
          file_ast: list(),
          docs_version: atom(),
          module_doc: map(),
          metadata: map(),
          docs: [%Docs{}],
          specs: list(),
          user_defined_functions: [{atom(), integer(), atom() | boolean()}],
          struct_type_spec: atom() | boolean(),
          properties: Keyword.t()
        }

  defstruct ~w(
    module
    file_full_path
    file_relative_path
    file_ast
    docs_version
    module_doc
    metadata
    docs
    specs
    user_defined_functions
    behaviours
    struct_type_spec
    properties
  )a

  @doc """
  Breaks down the docs format entry returned from Code.fetch_docs(MODULE)
  """
  def build({docs_version, _annotation, _language, _format, module_doc, metadata, docs}, module) do
    {:ok, module_specs} = Code.Typespec.fetch_specs(module)

    %ModuleInformation{
      module: module,
      behaviours: get_module_behaviours(module),
      file_full_path: get_full_file_path(module),
      file_relative_path: get_relative_file_path(module),
      file_ast: nil,
      docs_version: docs_version,
      module_doc: module_doc,
      metadata: metadata,
      docs: Enum.map(docs, &Docs.build/1),
      specs: Enum.map(module_specs, &Specs.build/1),
      user_defined_functions: nil,
      struct_type_spec: contains_struct_type_spec?(module),
      properties: [
        is_exception: is_exception?(module)
      ]
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
  Checks the provided module for a __struct__ function which is injected into the module
  whenever you use `defstruct`
  """
  def contains_struct_type_spec?(module) do
    cond do
      is_exception?(module) ->
        :not_struct

      is_struct?(module) ->
        {:ok, specs} = Code.Typespec.fetch_types(module)

        Enum.any?(specs, fn
          {:type, {:t, _, _}} -> true
          _ -> false
        end)

      true ->
        :not_struct
    end
  end

  defp is_struct?(module) do
    function_exported?(module, :__struct__, 0) or function_exported?(module, :__struct__, 1)
  end

  defp is_exception?(module) when is_atom(module) do
    function_exported?(module, :__struct__, 0) and :__exception__ in Map.keys(module.__struct__())
  end

  @doc """
  Given a ModuleInformation struct with the AST loaded, fetch all of the author defined functions
  """
  def load_user_defined_functions(%ModuleInformation{} = module_info) do
    {_ast, modules} = Macro.prewalk(module_info.file_ast, %{}, &parse_ast_node_for_defmodules/2)

    {_ast, %{functions: functions}} =
      modules
      |> Map.get(module_info.module)
      |> Macro.prewalk(%{last_impl: :none, functions: []}, &parse_ast_node_for_def/2)

    %{module_info | user_defined_functions: Enum.uniq(functions)}
    |> load_using_docs_and_specs()
  end

  defp load_using_docs_and_specs(%ModuleInformation{} = module_info) do
    {_ast, modules} = Macro.prewalk(module_info.file_ast, %{}, &parse_ast_node_for_defmodules/2)

    {_ast, using} =
      modules
      |> Map.get(module_info.module)
      |> Macro.prewalk(%{using: :none}, &parse_ast_for_using/2)

    acc = %{
      last_doc: :none,
      last_spec: :none,
      using_docs: [],
      using_specs: []
    }

    {_ast, extra} =
      using[:using]
      |> Macro.prewalk(acc, &parse_ast_using_node/2)

    %{
      module_info
      | specs: module_info.specs ++ extra.using_specs,
        docs: module_info.docs ++ extra.using_docs
    }
  end

  defp get_module_behaviours(module) do
    {_module, bin, _beam_file_path} = :code.get_object_code(module)

    case :beam_lib.chunks(bin, [:attributes]) do
      {:ok, {^module, attributes}} ->
        attributes
        |> Keyword.get(:attributes, [])
        |> Keyword.get(:behaviour, [])

      _ ->
        []
    end
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

  defp parse_ast_node_for_def({:@, _line_number, [{:doc, _, [false]}]} = ast, acc) do
    updated_acc = Map.put(acc, :last_impl, false)

    {ast, updated_acc}
  end

  defp parse_ast_node_for_def({:@, _line_number, [{:impl, _, impl_def}]} = ast, acc) do
    normalized_impl = normalize_impl(impl_def)
    updated_acc = Map.put(acc, :last_impl, normalized_impl)

    {ast, updated_acc}
  end

  defp parse_ast_node_for_def(
         {:def, _def_line, [{:when, _line_when, [{function_name, _function_line, args}, _guard]}, _do_block]} = ast,
         %{last_impl: impl} = acc
       ) do
    function_arity = get_function_arity(args)

    updated_acc = update_acc_for_def(acc, function_name, function_arity, impl)

    {ast, updated_acc}
  end

  defp parse_ast_node_for_def(
         {:def, _def_line, [{function_name, _function_line, args}, _do_block]} = ast,
         %{last_impl: impl} = acc
       ) do
    function_arity = get_function_arity(args)

    updated_acc = update_acc_for_def(acc, function_name, function_arity, impl)

    {ast, updated_acc}
  end

  defp parse_ast_node_for_def(
         {:def, _def_line, [{function_name, _function_line, args}]} = ast,
         %{last_impl: impl} = acc
       ) do
    function_arity = get_function_arity(args)

    updated_acc = update_acc_for_def(acc, function_name, function_arity, impl)

    {ast, updated_acc}
  end

  defp parse_ast_node_for_def(ast, acc) do
    {ast, acc}
  end

  defp update_acc_for_def(acc, function_name, function_arity, last_impl) do
    impl =
      case last_impl do
        :none ->
          acc[:functions]
          |> Enum.filter(fn {name, arity, _impl} -> name == function_name and arity == function_arity end)
          |> Enum.at(0, {function_name, function_arity, :none})
          |> Kernel.elem(2)

        last_impl ->
          last_impl
      end

    acc
    |> Map.put(:last_impl, :none)
    |> Map.update(:functions, [], fn functions ->
      [{function_name, function_arity, impl} | functions]
    end)
  end

  defp normalize_impl([value]) when is_boolean(value) do
    value
  end

  defp normalize_impl([{:__aliases__, _, module}]) do
    Module.concat(module)
  end

  defp normalize_impl(value) do
    value
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

  defp parse_ast_for_using({:defmacro, _macro_line, [{:__using__, _line, _args}, do_block]} = ast, _acc),
    do: {ast, %{using: do_block}}

  defp parse_ast_for_using(ast, acc), do: {ast, acc}

  defp parse_ast_using_node(
         {:@, _doc_line, [{:doc, _line, [doc]}]} = ast,
         acc
       ),
       do: {ast, Map.put(acc, :last_doc, doc)}

  defp parse_ast_using_node(
         {:@, _spec_line, [{:spec, _line, _spec_info}]} = ast,
         acc
       ),
       do: {ast, Map.put(acc, :last_spec, true)}

  defp parse_ast_using_node(
         {:def, _def_line, [{:when, _line_when, [{function_name, _function_line, args}, _guard]}, _do_block]} = ast,
         acc
       ) do
    {ast, update_acc_for_using(function_name, args, acc)}
  end

  defp parse_ast_using_node(
         {:def, _def_line, [{function_name, _function_line, args}, _do_block]} = ast,
         acc
       ) do
    {ast, update_acc_for_using(function_name, args, acc)}
  end

  defp parse_ast_using_node(
         {:def, _def_line, [{function_name, _function_line, args}]} = ast,
         acc
       ) do
    {ast, update_acc_for_using(function_name, args, acc)}
  end

  defp parse_ast_using_node(ast, acc), do: {ast, acc}

  defp update_acc_for_using(function_name, args, acc) do
    function_arity = get_function_arity(args)

    function_spec =
      if acc.last_spec != :none do
        [%Doctor.Specs{arity: function_arity, name: function_name}]
      else
        []
      end

    function_doc =
      if acc.last_doc != :none do
        [
          %Doctor.Docs{
            arity: function_arity,
            doc: %{"en" => acc.last_doc},
            kind: :function,
            name: function_name
          }
        ]
      else
        []
      end

    %{
      last_doc: :none,
      last_spec: :none,
      using_docs: acc.using_docs ++ function_doc,
      using_specs: acc.using_specs ++ function_spec
    }
  end
end
