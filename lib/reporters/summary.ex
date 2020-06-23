defmodule Doctor.Reporters.Summary do
  @moduledoc """
  This reporter generates a short summary documentation coverage report
  and lists overall how many modules passed/failed.
  """

  @behaviour Doctor.Reporter

  alias Elixir.IO.ANSI
  alias Doctor.ReportUtils

  @doc """
  Generate a short summary Doctor report and print to STDOUT
  """
  @impl true
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
    |> Mix.shell().info()
  end

  defp print_footer(pass, passed, failed, doc_coverage, spec_coverage) do
    doc_coverage = Decimal.round(doc_coverage, 1)
    spec_coverage = Decimal.round(spec_coverage, 1)

    print_divider()
    Mix.shell().info("Summary:\n")
    Mix.shell().info("Passed Modules: #{passed}")
    Mix.shell().info("Failed Modules: #{failed}")
    Mix.shell().info("Total Doc Coverage: #{doc_coverage}%")
    Mix.shell().info("Total Spec Coverage: #{spec_coverage}%\n")

    if pass do
      Mix.shell().info("Doctor validation has passed!")
    else
      Mix.shell().info(ANSI.red() <> "Doctor validation has failed!" <> ANSI.reset())
    end
  end
end
