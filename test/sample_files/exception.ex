defmodule Doctor.Exception do
  defexception [:message]

  @impl true
  def exception(value) do
    msg = "doctor exception: #{inspect(value)}"
    %Doctor.Exception{message: msg}
  end
end
