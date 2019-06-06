defmodule Doctor.Reporters.Short do
  @moduledoc """
  This reporter generates a full documentation coverage report and lists
  all the files in the project along with whether they pass or fail.
  """

  @behaviour Doctor.Reporter

  alias Mix.Shell.IO
  alias Doctor.{Reporters.OutputUtils, ReportUtils}

  @doc_cov_width 9
  @spec_cov_width 10
  @module_width 41
  @functions_width 11
  @docs_spec_missing_width 20
  @module_doc_width 10

  @doc """
  Generate a full Doctor report and print to STDOUT
  """
  def generate_report(module_reports, args) do
    print_divider()
    print_header()

    Enum.each(module_reports, fn module_report ->
      doc_cov = massage_coverage(module_report.doc_coverage)
      spec_cov = massage_coverage(module_report.spec_coverage)
      module_doc = massage_module_doc(module_report.has_module_doc)

      output_line =
        OutputUtils.generate_table_line([
          {doc_cov, @doc_cov_width},
          {spec_cov, @spec_cov_width},
          {module_report.functions, @functions_width},
          {module_report.module, @module_width},
          {module_doc, @module_doc_width}
        ])

      if ReportUtils.module_passed_validation?(module_report, args) do
        IO.info(output_line)
      else
        IO.error(output_line)
      end
    end)

    overall_pass = ReportUtils.doctor_report_passed?(module_reports, args)
    overall_passed = ReportUtils.count_total_passed_modules(module_reports, args)
    overall_failed = ReportUtils.count_total_failed_modules(module_reports, args)
    overall_doc_coverage = ReportUtils.calc_overall_doc_coverage(module_reports)
    overall_spec_coverage = ReportUtils.calc_overall_spec_coverage(module_reports)

    print_footer(
      overall_pass,
      overall_passed,
      overall_failed,
      overall_doc_coverage,
      overall_spec_coverage
    )
  end

  defp print_header() do
    output_header =
      OutputUtils.generate_table_line([
        {"Doc Cov", @doc_cov_width},
        {"Spec Cov", @spec_cov_width},
        {"Functions", @functions_width},
        {"Module", @module_width},
        {"Module Doc", @module_doc_width, 0}
      ])

    IO.info(output_header)
  end

  defp print_divider do
    "-"
    |> String.duplicate(81)
    |> IO.info()
  end

  defp print_footer(pass, passed, failed, doc_coverage, spec_coverage) do
    doc_coverage = Decimal.round(doc_coverage, 1)
    spec_coverage = Decimal.round(spec_coverage, 1)

    print_divider()
    IO.info("Summary:\n")
    IO.info("Passed Modules: #{passed}")
    IO.info("Failed Modules: #{failed}")
    IO.info("Total Doc Coverage: #{doc_coverage}%")
    IO.info("Total Spec Coverage: #{spec_coverage}%\n")

    if pass do
      IO.info("Doctor validation has passed!")
    else
      IO.error("Doctor validation has failed!")
    end
  end

  defp massage_coverage(coverage) do
    if coverage do
      "#{Decimal.round(coverage)}%"
    else
      "NA"
    end
  end

  defp massage_module_doc(module_doc) do
    if module_doc, do: "YES", else: "NO"
  end
end
