defmodule Doctor.Reporters.Summary do
  @behaviour Doctor.Reporter

  alias Mix.Shell.IO

  def generate_report(module_reports, args) do
    print_divider()

    results =
      Enum.reduce(module_reports, [], fn module_report, acc ->
        if module_passed_validation?(module_report, args) do
          [{:ok, module_report.coverage} | acc]
        else
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

  defp print_divider do
    IO.info("-----------------------")
  end

  defp print_footer(pass, passed, failed, coverage) do
    coverage =
      coverage
      |> Decimal.new()
      |> Decimal.round(1)

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

  defp module_passed_validation?(module_info, args) do
    if args.moduledoc_required do
      module_info.coverage >= args.min_module_coverage and module_info.module_doc
    else
      module_info.coverage >= args.min_module_coverage
    end
  end
end
