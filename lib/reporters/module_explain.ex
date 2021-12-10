defmodule Doctor.Reporters.ModuleExplain do
  @moduledoc """
  This module produces a report for a single project module. This
  is useful when you need to figure out exactly why a particular
  module failed validation. The only validations that are taken
  into account during this report are single module validations.
  In other words, the only thing that is checked are things that
  pertain to a single module like:
    - `min_module_doc_coverage`
    - `min_module_spec_coverage`
    - `moduledoc_required`
    - `exception_moduledoc_required`
    - `struct_type_spec_required`
  """

  alias Doctor.{Config, Docs, Specs}
  alias Doctor.{ModuleInformation, ModuleReport}
  alias Doctor.Reporters.OutputUtils

  @doc """
  Generate the output for a single module report
  """
  def generate_report(%ModuleInformation{} = module_information, %Config{} = config) do
    module_report = ModuleReport.build(module_information, config)

    user_defined_functions = module_information.user_defined_functions
    module_docs = module_information.docs
    module_specs = module_information.specs

    # Get max function name length
    # 13 is picked as the starting acc as that is the length of "Function Name"
    # which is the column header
    max_length =
      Enum.reduce(user_defined_functions, 13, fn {function, _arity, _impl}, acc ->
        length =
          function
          |> Atom.to_string()
          |> String.length()

        if length > acc, do: length, else: acc
      end)
      |> Kernel.+(5)

    # Print table header
    generate_header(max_length)
    OutputUtils.print_divider(max_length + 11)

    # Print per function information
    Enum.each(user_defined_functions, fn {function, arity, impl} ->
      function_name =
        function
        |> Atom.to_string()
        |> Kernel.<>("/#{arity}")
        |> OutputUtils.gen_fixed_width_string(max_length)

      has_doc =
        function
        |> has_doc(arity, impl, module_docs)
        |> OutputUtils.print_pass_or_fail()
        |> OutputUtils.gen_fixed_width_string(6)

      has_spec =
        function
        |> has_spec(arity, impl, module_specs)
        |> OutputUtils.print_pass_or_fail()
        |> OutputUtils.gen_fixed_width_string(6)

      Mix.shell().info("#{function_name}#{has_doc}#{has_spec}")
    end)

    # Print module summary info
    Mix.shell().info("\nModule Results:")
    print_doc_coverage(module_report, config)
    print_spec_coverage(module_report, config)
    print_module_doc(module_report, config)
    print_struct_spec(module_report, config)

    # Determine whether the module passed or failed
    valid_module?(module_report, config)
  end

  defp valid_module?(module_report, config) do
    valid_struct_spec?(module_report, config) and
      valid_moduledoc?(module_report, config) and
      valid_doc_coverage?(module_report, config) and
      valid_spec_coverage?(module_report, config)
  end

  defp valid_struct_spec?(module_report, config) do
    (config.struct_type_spec_required and module_report.has_struct_type_spec == :not_struct) or
      module_report.has_struct_type_spec
  end

  defp valid_moduledoc?(module_report, config) do
    (not config.exception_moduledoc_required and module_report.properties[:is_exception]) or
      (config.moduledoc_required and module_report.has_module_doc)
  end

  defp valid_doc_coverage?(module_report, config) do
    doc_coverage(module_report) >= config.min_module_doc_coverage
  end

  defp valid_spec_coverage?(module_report, config) do
    spec_coverage(module_report) >= config.min_module_spec_coverage
  end

  defp doc_coverage(module_report) do
    module_report.doc_coverage
    |> Decimal.round(1)
    |> Decimal.to_float()
  end

  defp spec_coverage(module_report) do
    module_report.spec_coverage
    |> Decimal.round(1)
    |> Decimal.to_float()
  end

  defp print_struct_spec(%ModuleReport{} = module_report, %Config{} = config) do
    if valid_struct_spec?(module_report, config) do
      OutputUtils.print_success(
        "  Has Struct Spec: #{OutputUtils.print_pass_or_fail(module_report.has_struct_type_spec)}"
      )
    else
      OutputUtils.print_error(
        "  Has Struct Spec: #{OutputUtils.print_pass_or_fail(module_report.has_struct_type_spec)}  --> Your config has a 'struct_type_spec_required' value of true"
      )
    end
  end

  defp print_module_doc(%ModuleReport{} = module_report, %Config{} = config) do
    if valid_moduledoc?(module_report, config) do
      OutputUtils.print_success("  Has Module Doc:  #{OutputUtils.print_pass_or_fail(module_report.has_module_doc)}")
    else
      config_option =
        case module_report.properties[:is_exception] do
          true ->
            "an 'exception_moduledoc_required'"

          _ ->
            "a 'moduledoc_required'"
        end

      OutputUtils.print_error(
        "  Has Module Doc:  #{OutputUtils.print_pass_or_fail(module_report.has_module_doc)}  --> Your config has #{
          config_option
        } value of true"
      )
    end
  end

  defp print_doc_coverage(%ModuleReport{} = module_report, %Config{} = config) do
    doc_coverage = doc_coverage(module_report)

    if doc_coverage >= config.min_module_doc_coverage do
      OutputUtils.print_success("  Doc Coverage:    #{doc_coverage}%")
    else
      OutputUtils.print_error(
        "  Doc Coverage:    #{doc_coverage}%  --> Your config has a 'min_module_doc_coverage' value of #{
          config.min_module_doc_coverage
        }"
      )
    end
  end

  defp print_spec_coverage(%ModuleReport{} = module_report, %Config{} = config) do
    spec_coverage = spec_coverage(module_report)

    if spec_coverage >= config.min_module_spec_coverage do
      OutputUtils.print_success("  Spec Coverage:   #{spec_coverage}%")
    else
      OutputUtils.print_error(
        "  Spec Coverage:   #{spec_coverage}%  --> Your config has a 'min_module_spec_coverage' value of #{
          config.min_module_spec_coverage
        }"
      )
    end
  end

  defp generate_header(function_name_length) do
    output_line =
      OutputUtils.generate_table_line([
        {"Function", function_name_length},
        {"@doc", 6},
        {"@spec", 7}
      ])

    Mix.shell().info("\n#{output_line}")
  end

  defp has_doc(function, arity, :none, module_docs) do
    Enum.any?(module_docs, fn
      %Docs{arity: ^arity, name: ^function, doc: doc} when doc != :none ->
        true

      _ ->
        false
    end)
  end

  defp has_doc(_, _, _, _) do
    true
  end

  defp has_spec(function, arity, :none, module_specs) do
    Enum.any?(module_specs, fn
      %Specs{arity: ^arity, name: ^function} -> true
      _ -> false
    end)
  end

  defp has_spec(_, _, _, _) do
    true
  end
end
