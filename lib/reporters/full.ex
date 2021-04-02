defmodule Doctor.Reporters.Full do
  @moduledoc """
  This reporter generates a full documentation coverage report and lists
  all the files in the project along with whether they pass or fail.
  """

  @behaviour Doctor.Reporter

  alias Doctor.{Reporters.OutputUtils, ReportUtils}
  alias Elixir.IO.ANSI

  @doc_cov_width 9
  @spec_cov_width 10
  @module_width 41
  @file_width 58
  @functions_width 11
  @missed_docs_width 9
  @missed_specs_width 10
  @module_doc_width 12
  @struct_type_spec_width 11

  @doc """
  Generate a full Doctor report and print to STDOUT
  """
  @impl true
  def generate_report(module_reports, args) do
    print_divider()
    print_header()

    Enum.each(module_reports, fn module_report ->
      doc_cov = massage_coverage(module_report.doc_coverage)
      spec_cov = massage_coverage(module_report.spec_coverage)
      module_doc = massage_module_doc(module_report.has_module_doc)
      struct_type_spec = massage_struct_type_spec(module_report.has_struct_type_spec)

      output_line =
        OutputUtils.generate_table_line([
          {doc_cov, @doc_cov_width},
          {spec_cov, @spec_cov_width},
          {module_report.module, @module_width},
          {module_report.file, @file_width},
          {module_report.functions, @functions_width},
          {module_report.missed_docs, @missed_docs_width},
          {module_report.missed_specs, @missed_specs_width},
          {module_doc, @module_doc_width},
          {struct_type_spec, @struct_type_spec_width, 0}
        ])

      if ReportUtils.module_passed_validation?(module_report, args) do
        unless args.failed do
          Mix.shell().info(output_line)
        end
      else
        Mix.shell().info(ANSI.red() <> output_line <> ANSI.reset())
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
        {"Module", @module_width},
        {"File", @file_width},
        {"Functions", @functions_width},
        {"No Docs", @missed_docs_width},
        {"No Specs", @missed_specs_width},
        {"Module Doc", @module_doc_width},
        {"Struct Spec", @struct_type_spec_width, 0}
      ])

    Mix.shell().info(output_header)
  end

  defp print_divider do
    "-"
    |> String.duplicate(171)
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

  defp massage_coverage(coverage) do
    if coverage do
      "#{Decimal.round(coverage)}%"
    else
      "N/A"
    end
  end

  defp massage_module_doc(module_doc) do
    if module_doc, do: "Yes", else: "No"
  end

  defp massage_struct_type_spec(:not_struct), do: "N/A"
  defp massage_struct_type_spec(true), do: "Yes"
  defp massage_struct_type_spec(false), do: "No"
end
