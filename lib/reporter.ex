defmodule Doctor.Reporter do
  @type module_reports :: [Doctor.ModuleReport.t()]

  @callback generate_report(module_reports, any()) :: :ok | :error
end
