defmodule Doctor.HiddenDocs do
  @moduledoc false

  @spec func_1(integer()) :: integer()
  @doc "Function doc 1"
  def func_1(input) do
    input + 1
  end
end
