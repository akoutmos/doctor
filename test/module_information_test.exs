defmodule Doctor.ModuleInformationTest do
  use ExUnit.Case

  alias Doctor.{ModuleInformation, ModuleReport}

  describe "build/2" do
    test "should find all of the docs for a module where all docs are present" do
      full_func_list = [:func_1, :func_2, :func_3, :func_4, :func_5, :func_5, :func_6]

      module_information =
        Doctor.AllDocs
        |> Code.fetch_docs()
        |> ModuleInformation.build(Doctor.AllDocs)

      docs =
        module_information.docs
        |> Enum.map(fn func_doc ->
          func_doc.name
        end)
        |> Enum.sort()

      specs =
        module_information.specs
        |> Enum.map(fn func_spec ->
          func_spec.name
        end)
        |> Enum.sort()

      assert is_map(module_information.module_doc)
      assert module_information.file_ast == nil
      assert module_information.file_relative_path == "test/sample_files/all_docs.ex"
      assert specs == full_func_list
      assert docs == full_func_list
    end

    test "should report behaviour functions properly" do
      module_report =
        Doctor.AnotherBehaviourModule
        |> Code.fetch_docs()
        |> ModuleInformation.build(Doctor.AnotherBehaviourModule)
        |> ModuleInformation.load_file_ast()
        |> ModuleInformation.load_user_defined_functions()
        |> ModuleReport.build(%Doctor.Config{})

      assert module_report.missed_specs == 0
      assert module_report.missed_docs == 0
    end
  end

  test "load_user_defined_functions/1 should load user defined functions from AST" do
    module_information =
      Doctor.AllDocs
      |> Code.fetch_docs()
      |> ModuleInformation.build(Doctor.AllDocs)
      |> ModuleInformation.load_file_ast()
      |> ModuleInformation.load_user_defined_functions()

    assert module_information != nil

    assert Enum.sort(module_information.user_defined_functions) == [
             {:func_1, 1, :none},
             {:func_2, 1, :none},
             {:func_3, 1, :none},
             {:func_4, 1, :none},
             {:func_5, 2, :none},
             {:func_5, 3, :none},
             {:func_6, 1, :none}
           ]
  end
end
