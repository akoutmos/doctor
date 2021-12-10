defmodule Doctor.ReportUtilsTest do
  use ExUnit.Case

  alias Doctor.{ModuleInformation, ModuleReport, ReportUtils}

  setup do
    reports =
      [Doctor.AllDocs, Doctor.PartialDocs, Doctor.NoDocs]
      |> Enum.map(fn module ->
        report =
          module
          |> Code.fetch_docs()
          |> ModuleInformation.build(module)
          |> ModuleInformation.load_file_ast()
          |> ModuleInformation.load_user_defined_functions()
          |> ModuleReport.build(%Doctor.Config{})

        {module, report}
      end)
      |> Map.new()

    %{reports: reports}
  end

  test "count_total_functions/1 should return the correct number of functions across a list of module reports",
       %{reports: reports} do
    assert reports
           |> Map.values()
           |> ReportUtils.count_total_functions() == 21
  end

  test "count_total_documented_functions/1 should return the correct number of documented functions across a list of module reports",
       %{reports: reports} do
    assert reports
           |> Map.values()
           |> ReportUtils.count_total_documented_functions() == 11
  end

  test "count_total_speced_functions/1 should return the correct number of speced functions across a list of module reports",
       %{reports: reports} do
    assert reports
           |> Map.values()
           |> ReportUtils.count_total_speced_functions() == 11
  end

  test "count_total_passed_modules/1 should return the correct number of failed modules from a list of module reports if moduledoc config true",
       %{reports: reports} do
    config = %Doctor.Config{moduledoc_required: true}

    assert reports
           |> Map.values()
           |> ReportUtils.count_total_passed_modules(config) == 1
  end

  test "count_total_passed_modules/1 should return the correct number of failed modules from a list of module reports if config threshold set low",
       %{reports: reports} do
    config = %Doctor.Config{min_overall_doc_coverage: 20, moduledoc_required: false}

    assert reports
           |> Map.values()
           |> ReportUtils.count_total_passed_modules(config) == 2
  end

  test "count_total_failed_modules/1 should return the correct number of failed modules from a list of module reports if moduledoc config true",
       %{reports: reports} do
    config = %Doctor.Config{moduledoc_required: true}

    assert reports
           |> Map.values()
           |> ReportUtils.count_total_failed_modules(config) == 2
  end

  test "count_total_failed_modules/1 should return the correct number of failed modules from a list of module reports if config threshold set low",
       %{reports: reports} do
    config = %Doctor.Config{min_overall_doc_coverage: 20, moduledoc_required: false}

    assert reports
           |> Map.values()
           |> ReportUtils.count_total_failed_modules(config) == 1
  end

  test "calc_overall_doc_coverage/1 should return the correct percentage a list of module reports",
       %{reports: reports} do
    assert reports
           |> Map.values()
           |> ReportUtils.calc_overall_doc_coverage() ==
             Decimal.new("52.38095238095238095238095238")
  end

  test "calc_overall_spec_coverage/1 should return the correct percentage a list of module reports",
       %{reports: reports} do
    assert reports
           |> Map.values()
           |> ReportUtils.calc_overall_spec_coverage() ==
             Decimal.new("52.38095238095238095238095238")
  end

  test "doctor_report_passed?/2 should return false if the report fails given required moduledocs",
       %{
         reports: reports
       } do
    config = %Doctor.Config{moduledoc_required: true}

    refute reports
           |> Map.values()
           |> ReportUtils.doctor_report_passed?(config)
  end

  test "doctor_report_passed?/2 should return false if the report fails given high threshold", %{
    reports: reports
  } do
    config = %Doctor.Config{
      moduledoc_required: false,
      min_module_doc_coverage: 0,
      min_overall_doc_coverage: 80
    }

    refute reports
           |> Map.values()
           |> ReportUtils.doctor_report_passed?(config)
  end

  test "doctor_report_passed?/2 should return false if the report fails given low threshold", %{
    reports: reports
  } do
    config = %Doctor.Config{
      moduledoc_required: false,
      min_module_doc_coverage: 0,
      min_overall_doc_coverage: 50
    }

    assert reports
           |> Map.values()
           |> ReportUtils.doctor_report_passed?(config)
  end
end
