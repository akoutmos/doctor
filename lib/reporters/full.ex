defmodule Doctor.Reporters.Full do
  @behaviour Doctor.Reporter

  alias Mix.Shell.IO
  alias Doctor.ModuleReport

  def generate_report(module_reports, args) do
    print_divider()
    print_header()

    results =
      Enum.reduce(module_reports, [], fn module_report, acc ->
        doc_cov =
          module_report.doc_coverage
          |> massage_coverage()
          |> gen_fixed_width_string(8)

        spec_cov =
          module_report.spec_coverage
          |> massage_coverage()
          |> gen_fixed_width_string(9)

        module_doc =
          module_report.has_module_doc
          |> massage_module_doc()
          |> gen_fixed_width_string(10)

        file = gen_fixed_width_string(module_report.file, 51)
        functions = gen_fixed_width_string(module_report.functions, 10)
        missed_docs = gen_fixed_width_string(module_report.missed_docs, 12)
        missed_specs = gen_fixed_width_string(module_report.missed_specs, 13)

        if module_passed_validation?(module_report, args) do
          IO.info(
            "#{doc_cov}#{spec_cov}#{file}#{functions}#{missed_docs}#{missed_specs}#{module_doc}"
          )

          [{:ok, module_report.doc_coverage, module_report.spec_coverage} | acc]
        else
          IO.error(
            "#{doc_cov}#{spec_cov}#{file}#{functions}#{missed_docs}#{missed_specs}#{module_doc}"
          )

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

  defp print_header() do
    IO.info(
      "DOC_COV SPEC_COV FILE                                               FUNCTIONS MISSED_DOCS MISSED_SPECS MODULE_DOC"
    )
  end

  defp print_divider do
    IO.info(
      "-----------------------------------------------------------------------------------------------------------------"
    )
  end

  defp print_footer(pass, passed, failed, doc_coverage, spec_coverage) do
    doc_coverage =
      doc_coverage
      |> Decimal.from_float()
      |> Decimal.round(1)

    spec_coverage =
      spec_coverage
      |> Decimal.from_float()
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

  defp gen_fixed_width_string(value, width, padding \\ 2)

  defp gen_fixed_width_string(value, width, padding) when is_integer(value) do
    value
    |> Integer.to_string()
    |> gen_fixed_width_string(width, padding)
  end

  defp gen_fixed_width_string(value, width, padding) do
    sub_string_length = width - (padding + 1)

    value
    |> String.slice(0..sub_string_length)
    |> String.pad_trailing(width)
  end

  defp massage_coverage(coverage) do
    if coverage do
      "#{round(coverage)}%"
    else
      "NA"
    end
  end

  defp massage_module_doc(module_doc) do
    if module_doc, do: "YES", else: "NO"
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
