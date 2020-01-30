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
  Calculate the overal doc coverage in the codebase
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
  Calculate the overal spec coverage in the codebase
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
          has_module_doc: has_module_doc
        },
        %Config{} = config
      ) do
    doc_cov = calc_coverage_pass(doc_coverage, config.min_module_doc_coverage)
    spec_cov = calc_coverage_pass(spec_coverage, config.min_module_spec_coverage)

    if config.moduledoc_required do
      doc_cov and spec_cov and has_module_doc
    else
      doc_cov and spec_cov
    end
  end

  @doc """
  Check whether Doctor overall has passed or failed validation
  """
  def doctor_report_passed?(module_report_list, %Config{} = config) do
    all_modules_pass =
      module_report_list
      |> Enum.reduce_while(false, fn module_report, _acc ->
        if module_passed_validation?(module_report, config) do
          {:cont, true}
        else
          {:halt, false}
        end
      end)

    overall_doc_cov_pass =
      module_report_list
      |> calc_overall_doc_coverage()
      |> Decimal.to_float()
      |> Kernel.>=(config.min_overall_doc_coverage)

    overall_spec_cov_pass =
      module_report_list
      |> calc_overall_spec_coverage()
      |> Decimal.to_float()
      |> Kernel.>=(config.min_overall_spec_coverage)

    all_modules_pass and overall_doc_cov_pass and overall_spec_cov_pass
  end

  defp calc_coverage_pass(coverage, threshold) when not is_nil(coverage) do
    Decimal.to_float(coverage) >= threshold
  end

  defp calc_coverage_pass(_coverage, _threshold), do: true
end
