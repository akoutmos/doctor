defmodule Doctor.Reporters.Summary do
  @moduledoc """
  This reporter generates a short summary documentation coverage report
  and lists overall how many modules passed/failed.
  """

  @behaviour Doctor.Reporter

  alias Mix.Shell.IO
  alias Doctor.ReportUtils

  @doc """
  Generate a short summary Doctor report and print to STDOUT
  """
  def generate_report(module_reports, args) do
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

  defp print_divider do
    "-"
    |> String.duplicate(45)
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
end
