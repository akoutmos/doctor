defmodule Mix.Tasks.Doctor.Gen.Config do
  @moduledoc false

  use Mix.Task

  alias Mix.Shell.IO
  alias Doctor.Config

  @shortdoc "Creates a .doctor.exs config file with defaults"

  @doc """
  This Mix task generates a .doctor.exs configuration file
  """
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
