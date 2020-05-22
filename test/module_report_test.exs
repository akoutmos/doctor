defmodule Doctor.ModuleReportTest do
  use ExUnit.Case

  alias Doctor.{ModuleInformation, ModuleReport}

  test "build/1 should build the correct report struct for a file with full coverage" do
    module_report =
      Doctor.AllDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.AllDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build()

    assert module_report.functions == 7
    assert module_report.has_module_doc
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.AllDocs"
    assert module_report.doc_coverage == Decimal.new("100")
  end

  test "build/1 should build the correct report struct for a file with partial coverage" do
    module_report =
      Doctor.PartialDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.PartialDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build()

    assert module_report.functions == 7
    refute module_report.has_module_doc
    assert module_report.missed_docs == 3
    assert module_report.missed_specs == 3
    assert module_report.module == "Doctor.PartialDocs"
    assert module_report.doc_coverage == Decimal.new("57.14285714285714285714285714")
  end

  test "build/1 should build the correct report struct for a file that implements behaviour callbacks" do
    module_report =
      Doctor.BehaviourModule
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.BehaviourModule)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build()

    assert module_report.functions == 3
    assert module_report.has_module_doc
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.BehaviourModule"
    assert module_report.doc_coverage == Decimal.new("100")
  end

  test "build/1 should build the correct report struct for a file with no coverage" do
    module_report =
      Doctor.NoDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.NoDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build()

    assert module_report.functions == 7
    refute module_report.has_module_doc
    assert module_report.missed_docs == 7
    assert module_report.missed_specs == 7
    assert module_report.module == "Doctor.NoDocs"
    assert module_report.doc_coverage == Decimal.new("0")
  end
end
