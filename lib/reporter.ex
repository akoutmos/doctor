defmodule Doctor.Reporter do
  @moduledoc """
  Defines the behaviour for a reporter
  """

  @type module_reports :: [Doctor.ModuleReport.t()]

  @callback generate_report(module_reports, any()) :: :ok | :error
end
