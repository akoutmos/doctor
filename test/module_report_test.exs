defmodule Doctor.ModuleReportTest do
  use ExUnit.Case

  alias Doctor.{ModuleInformation, ModuleReport}

  test "build/2 should build the correct report struct for a file with full coverage" do
    module_report =
      Doctor.AllDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.AllDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 7
    assert module_report.has_module_doc
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.AllDocs"
    assert module_report.doc_coverage == Decimal.new("100")
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report struct for a file with partial coverage" do
    module_report =
      Doctor.PartialDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.PartialDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 7
    refute module_report.has_module_doc
    assert module_report.missed_docs == 3
    assert module_report.missed_specs == 3
    assert module_report.module == "Doctor.PartialDocs"
    assert module_report.doc_coverage == Decimal.new("57.14285714285714285714285714")
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report struct for a file that implements behaviour callbacks" do
    module_report =
      Doctor.BehaviourModule
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.BehaviourModule)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 3
    assert module_report.has_module_doc
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.BehaviourModule"
    assert module_report.doc_coverage == Decimal.new("100")
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report struct for a file that implements behaviour callbacks with multiple clauses" do
    module_report =
      Doctor.FooBar
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.FooBar)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 6
    assert module_report.has_module_doc
    assert module_report.missed_docs == 1
    assert module_report.missed_specs == 3
    assert module_report.module == "Doctor.FooBar"
    assert module_report.doc_coverage == Decimal.new("83.33333333333333333333333333")
    assert module_report.spec_coverage == Decimal.new("50.0")
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report struct for a file with no coverage" do
    module_report =
      Doctor.NoDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.NoDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 7
    refute module_report.has_module_doc
    assert module_report.missed_docs == 7
    assert module_report.missed_specs == 7
    assert module_report.module == "Doctor.NoDocs"
    assert module_report.doc_coverage == Decimal.new("0")
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report struct for a file with struct specs" do
    module_report =
      Doctor.StructSpecModule
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.StructSpecModule)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 0
    refute module_report.has_module_doc
    assert module_report.has_struct_type_spec
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.StructSpecModule"
    assert module_report.doc_coverage == nil
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report struct for a file with no struct specs" do
    module_report =
      Doctor.NoStructSpecModule
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.NoStructSpecModule)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 0
    refute module_report.has_module_doc
    refute module_report.has_struct_type_spec
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.NoStructSpecModule"
    assert module_report.doc_coverage == nil
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report for an exception" do
    module_report =
      Doctor.Exception
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.Exception)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 1
    refute module_report.has_module_doc
    assert module_report.has_struct_type_spec
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.Exception"
    assert module_report.doc_coverage == Decimal.new("100")
    assert module_report.properties == [is_exception: true]
  end

  test "build/2 should build the correct report for a module wiht __using__ macro" do
    module_report =
      Doctor.UseModule
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.UseModule)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(%Doctor.Config{})

    assert module_report.functions == 4
    assert module_report.has_module_doc
    assert module_report.has_struct_type_spec == :not_struct
    assert module_report.missed_docs == 2
    assert module_report.missed_specs == 2
    assert module_report.module == "Doctor.UseModule"
    assert module_report.doc_coverage == Decimal.new("50.0")
    assert module_report.spec_coverage == Decimal.new("50.0")
    assert module_report.properties == [is_exception: false]
  end

  test "build/2 should build the correct report struct for a file with hidden docs" do
    args = %Doctor.Config{
      include_hidden_doc: true
    }

    module_report =
      Doctor.HiddenDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.HiddenDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()
      |> ModuleReport.build(args)

    assert module_report.functions == 1
    refute module_report.has_module_doc
    assert module_report.missed_docs == 0
    assert module_report.missed_specs == 0
    assert module_report.module == "Doctor.HiddenDocs"
    assert module_report.doc_coverage == Decimal.new("100")
    assert module_report.properties == [is_exception: false]
  end
end
