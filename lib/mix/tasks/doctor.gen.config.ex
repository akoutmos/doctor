defmodule Mix.Tasks.Doctor.Gen.Config do
  use Mix.Task

  alias Mix.Shell.IO
  alias Doctor.Config

  @shortdoc "Creates a .doctor.exs config file with defaults"
  @config_file ".doctor.exs"

  def run(_args) do
    create_file =
      if File.exists?(@config_file) do
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
    file_path =
      File.cwd!()
      |> Path.join(Config.config_file())

    File.write(file_path, Config.config_defaults_as_string())
  end
end
