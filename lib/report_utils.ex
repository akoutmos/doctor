defmodule Doctor.ReportUtils do
  @moduledoc """
  This module provides some utility functions for use in report generators.
  """

  alias Doctor.{Config, ModuleReport}

  @doc """
  Given a list of module reports, count the total number of functions
  """
  def count_total_functions(module_report_list) do
    module_report_list
    |> Enum.reduce(0, fn module_report, acc ->
      module_report.functions + acc
    end)
  end

  @doc """
  Given a list of module reports, count the total number of documented functions
  """
  def count_total_documented_functions(module_report_list) do
    module_report_list
    |> Enum.reduce(0, fn module_report, acc ->
      module_documented_functions = module_report.functions - module_report.missed_docs

      module_documented_functions + acc
    end)
  end

  @doc """
  Given a list of module reports, count the total number of speced functions
  """
  def count_total_speced_functions(module_report_list) do
    module_report_list
    |> Enum.reduce(0, fn module_report, acc ->
      module_speced_functions = module_report.functions - module_report.missed_specs

      module_speced_functions + acc
    end)
  end

  @doc """
  Given a list of module reports, count the total number of passed modules
  """
  def count_total_passed_modules(module_report_list, %Config{} = config) do
    module_report_list
    |> Enum.count(fn module_report ->
      module_passed_validation?(module_report, config)
    end)
  end

  @doc """
  Given a list of module reports, count the total number of failed modules
  """
  def count_total_failed_modules(module_report_list, %Config{} = config) do
    module_report_list
    |> Enum.count(fn module_report ->
      not module_passed_validation?(module_report, config)
    end)
  end

  @doc """
  Calculate the overall doc coverage in the codebase
  """
  def calc_overall_doc_coverage(module_report_list) do
    total_functions = count_total_functions(module_report_list)
    documented_functions = count_total_documented_functions(module_report_list)

    if total_functions > 0 do
      documented_functions
      |> Decimal.div(total_functions)
      |> Decimal.mult(100)
    else
      Decimal.new(0)
    end
  end

  @doc """
  Calculate the ratio of modules which have a moduledoc.
  """
  def calc_overall_moduledoc_coverage(module_report_list) do
    {all_modules, with_moduledoc} =
      Enum.reduce(module_report_list, {0, 0}, fn
        %{is_protocol_implementation: true}, {acc_all, acc_with} -> {acc_all, acc_with}
        %{has_module_doc: true}, {acc_all, acc_with} -> {acc_all + 1, acc_with + 1}
        %{has_module_doc: false}, {acc_all, acc_with} -> {acc_all + 1, acc_with}
      end)

    with_moduledoc
    |> Decimal.div(all_modules)
    |> Decimal.mult(100)
  end

  @doc """
  Calculate the overall spec coverage in the codebase
  """
  def calc_overall_spec_coverage(module_report_list) do
    total_functions = count_total_functions(module_report_list)
    speced_functions = count_total_speced_functions(module_report_list)

    if total_functions > 0 do
      speced_functions
      |> Decimal.div(total_functions)
      |> Decimal.mult(100)
    else
      Decimal.new(0)
    end
  end

  @doc """
  Checks whether the provided module passed validation
  """
  def module_passed_validation?(
        %ModuleReport{
          doc_coverage: doc_coverage,
          spec_coverage: spec_coverage,
          has_struct_type_spec: has_struct_type_spec
        } = module_report,
        %Config{} = config
      ) do
    doc_cov = calc_coverage_pass(doc_coverage, config.min_module_doc_coverage)
    spec_cov = calc_coverage_pass(spec_coverage, config.min_module_spec_coverage)
    passed_module_doc = valid_module_doc?(module_report, config)

    passed_struct_type_spec =
      if config.struct_type_spec_required and has_struct_type_spec != :not_struct,
        do: has_struct_type_spec,
        else: true

    doc_cov and spec_cov and passed_struct_type_spec and passed_module_doc
  end

  defp valid_module_doc?(%ModuleReport{is_protocol_implementation: true}, _config) do
    true
  end

  defp valid_module_doc?(%ModuleReport{properties: properties} = module_report, config) do
    if Keyword.get(properties, :is_exception) do
      if config.exception_moduledoc_required do
        module_report.has_module_doc
      else
        true
      end
    else
      if Config.moduledoc_required?(config),
        do: module_report.has_module_doc,
        else: true
    end
  end

  @doc """
  Check whether Doctor overall has passed or failed validation
  """
  def doctor_report_passed?(module_report_list, config) do
    [] == doctor_report_errors(module_report_list, config)
  end

  @doc """
  Check whether Doctor overall has passed or failed validation
  """
  @spec doctor_report_errors([Doctor.ModuleReport.t()], Config.t()) :: [String.t()]
  def doctor_report_errors(module_report_list, %Config{} = config) do
    msg = fn
      true, _msg -> []
      false, msg -> [msg]
    end

    all_modules =
      module_report_list
      |> Enum.reduce_while([], fn module_report, _acc ->
        if module_passed_validation?(module_report, config) do
          {:cont, []}
        else
          {:halt, ["one or more highlighted modules above is unhealthy"]}
        end
      end)

    overall_doc_cov =
      module_report_list
      |> calc_overall_doc_coverage()
      |> Decimal.to_float()
      |> Kernel.>=(config.min_overall_doc_coverage)
      |> msg.("overall @doc coverage is below #{config.min_overall_doc_coverage}")

    overall_moduledoc_cov =
      module_report_list
      |> calc_overall_moduledoc_coverage()
      |> Decimal.to_float()
      |> Kernel.>=(config.min_overall_moduledoc_coverage)
      |> msg.("overall @moduledoc coverage is below #{config.min_overall_moduledoc_coverage}")

    overall_spec_cov =
      module_report_list
      |> calc_overall_spec_coverage()
      |> Decimal.to_float()
      |> Kernel.>=(config.min_overall_spec_coverage)
      |> msg.("overall @spec coverage is below #{config.min_overall_spec_coverage}")

    all_modules ++ overall_doc_cov ++ overall_moduledoc_cov ++ overall_spec_cov
  end

  defp calc_coverage_pass(coverage, threshold) when not is_nil(coverage) do
    Decimal.to_float(coverage) >= threshold
  end

  defp calc_coverage_pass(_coverage, _threshold), do: true
end
