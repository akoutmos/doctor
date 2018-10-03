defmodule Doctor.Reporters.Full do
  @behaviour Doctor.Reporter

  alias Mix.Shell.IO

  def generate_report(module_reports, args) do
    print_divider()
    print_header()

    results =
      Enum.reduce(module_reports, [], fn module_report, acc ->
        cov =
          module_report.coverage
          |> massage_coverage()
          |> gen_fixed_width_string(7)

        module_doc =
          module_report.module_doc
          |> massage_module_doc()
          |> gen_fixed_width_string(10)

        file = gen_fixed_width_string(module_report.file, 51)
        functions = gen_fixed_width_string(module_report.functions, 10)
        missed = gen_fixed_width_string(module_report.missed, 7)

        if module_passed_validation?(module_report, args) do
          IO.info("#{cov}#{file}#{functions}#{missed}#{module_doc}")

          [{:ok, module_report.coverage} | acc]
        else
          IO.error("#{cov}#{file}#{functions}#{missed}#{module_doc}")

          [{:error, module_report.coverage} | acc]
        end
      end)

    overall_pass =
      Enum.reduce_while(results, true, fn
        {:ok, _}, _acc -> {:cont, true}
        {:error, _}, _acc -> {:halt, false}
      end)

    {overall_passed, overall_failed} =
      Enum.reduce(results, {0, 0}, fn
        {:ok, _}, {passed, failed} -> {passed + 1, failed}
        {:error, _}, {passed, failed} -> {passed, failed + 1}
      end)

    overall_coverage =
      Enum.reduce(results, 0.0, fn
        {_, nil}, acc -> acc
        {_, coverage}, acc -> acc + coverage
      end) / length(results)

    print_footer(overall_pass, overall_passed, overall_failed, overall_coverage)

    overall_pass
  end

  defp print_header() do
    IO.info(
      "COV    FILE                                               FUNCTIONS MISSED MODULE_DOC"
    )
  end

  defp print_divider do
    IO.info(
      "-------------------------------------------------------------------------------------"
    )
  end

  defp print_footer(pass, passed, failed, coverage) do
    coverage =
      coverage
      |> Decimal.new()
      |> Decimal.round(1)

    print_divider()
    IO.info("Summary:\n")
    IO.info("Passed Modules: #{passed}")
    IO.info("Failed Modules: #{failed}")
    IO.info("Total Coverage: #{coverage}%\n")

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

  defp module_passed_validation?(module_info, args) do
    if args.moduledoc_required do
      module_info.coverage >= args.min_module_coverage and module_info.module_doc
    else
      module_info.coverage >= args.min_module_coverage
    end
  end
end
