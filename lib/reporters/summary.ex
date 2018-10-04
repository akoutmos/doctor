defmodule Doctor.Reporters.Summary do
  @behaviour Doctor.Reporter

  alias Mix.Shell.IO
  alias Doctor.ModuleReport

  def generate_report(module_reports, args) do
    print_divider()

    results =
      Enum.reduce(module_reports, [], fn module_report, acc ->
        if module_passed_validation?(module_report, args) do
          [{:ok, module_report.doc_coverage, module_report.spec_coverage} | acc]
        else
          [{:error, module_report.doc_coverage, module_report.spec_coverage} | acc]
        end
      end)

    overall_pass =
      Enum.reduce_while(results, true, fn
        {:ok, _, _}, _acc -> {:cont, true}
        {:error, _, _}, _acc -> {:halt, false}
      end)

    {overall_passed, overall_failed} =
      Enum.reduce(results, {0, 0}, fn
        {:ok, _, _}, {passed, failed} -> {passed + 1, failed}
        {:error, _, _}, {passed, failed} -> {passed, failed + 1}
      end)

    overall_doc_coverage =
      Enum.reduce(results, 0.0, fn
        {_, nil, _}, acc -> acc
        {_, coverage, _}, acc -> acc + coverage
      end) / length(results)

    overall_spec_coverage =
      Enum.reduce(results, 0.0, fn
        {_, _, nil}, acc -> acc
        {_, _, coverage}, acc -> acc + coverage
      end) / length(results)

    print_footer(
      overall_pass,
      overall_passed,
      overall_failed,
      overall_doc_coverage,
      overall_spec_coverage
    )

    # TODO: Take into account config overall values
    overall_pass
  end

  defp print_divider do
    IO.info("-----------------------")
  end

  defp print_footer(pass, passed, failed, doc_coverage, spec_coverage) do
    doc_coverage =
      doc_coverage
      |> Decimal.new()
      |> Decimal.round(1)

    spec_coverage =
      spec_coverage
      |> Decimal.new()
      |> Decimal.round(1)

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

  defp module_passed_validation?(%ModuleReport{} = module_report, args) do
    # TODO: This should be moved to a share module so reporters don't repeat it
    if args.moduledoc_required do
      module_report.doc_coverage >= args.min_module_doc_coverage and
        module_report.spec_coverage >= args.min_module_spec_coverage and
        module_report.has_module_doc
    else
      module_report.doc_coverage >= args.min_module_doc_coverage and
        module_report.spec_coverage >= args.min_module_spec_coverage
    end
  end
end
