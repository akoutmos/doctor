defmodule Doctor.ConfigTest do
  use ExUnit.Case, async: true
  alias Doctor.Config

  test "config_defaults_as_string" do
    assert """
           %Doctor.Config{
             exception_moduledoc_required: true,
             failed: false,
             ignore_modules: [],
             ignore_paths: [],
             min_module_doc_coverage: 40,
             min_module_spec_coverage: 0,
             min_overall_doc_coverage: 50,
             min_overall_moduledoc_coverage: 100,
             min_overall_spec_coverage: 0,
             raise: false,
             reporter: Doctor.Reporters.Full,
             struct_type_spec_required: true,
             umbrella: false
           }\
           """ == "#{Config.config_defaults_as_string()}"
  end
end
