defmodule Mix.Tasks.Doctor.Gen.Config do
  @moduledoc """
  Doctor is a command line utility that can be used to ensure that your project
  documentation remains healthy. For more in depth documentation on Doctor or to
  file bug/feature requests, please check out https://github.com/akoutmos/doctor.

  The `mix doctor.gen.config` command can be used to create a `.doctor.exs` file
  with the default Doctor settings. The default file contents are:

  ```
  %Doctor.Config{
    ignore_modules: [],
    ignore_paths: [],
    min_module_doc_coverage: 40,
    min_module_spec_coverage: 0,
    min_overall_doc_coverage: 50,
    min_overall_spec_coverage: 0,
    moduledoc_required: true,
    exception_moduledoc_required: true,
    raise: false,
    reporter: Doctor.Reporters.Full,
    struct_type_spec_required: true,
    umbrella: false,
    include_hidden_doc: false
  }
  ```
  """

  use Mix.Task

  alias Mix.Shell.IO
  alias Doctor.Config

  @shortdoc "Creates a .doctor.exs config file with defaults"

  @doc """
  This Mix task generates a .doctor.exs configuration file
  """
  @impl true
  def run(_args) do
    create_file =
      if File.exists?(Config.config_file()) do
        IO.yes?("An existing Doctor config file already exists. Overwrite?")
      else
        true
      end

    if create_file do
      create_config_file()

      IO.info("Successfully created .doctor.exs file.")
    else
      IO.info("Did not create .doctor.exs file.")
    end
  end

  defp create_config_file do
    File.cwd!()
    |> Path.join(Config.config_file())
    |> File.write(Config.config_defaults_as_string())
  end
end
