defmodule Doctor.AllDocs do
  @moduledoc "This is a module doc"

  @spec func_1(integer()) :: integer()
  @doc "Function doc 1"
  def func_1(input) do
    input + 1
  end

  @spec func_2(integer()) :: integer()
  @doc """
  Function doc 2
  """
  def func_2(input), do: input + 2

  @spec func_3(integer()) :: integer()
  @doc "Function doc 3"
  def func_3(input) when is_integer(input) do
    input + 3
  end

  @spec func_4(integer()) :: integer()
  @doc "Function doc 4"
  def func_4(input) when is_integer(input), do: input + 4

  @spec func_5(integer(), integer()) :: integer()
  @doc "Function doc 5 with 2 args"
  def func_5(input_1, input_2) do
    func_5(input_1, input_2, 5)
  end

  @spec func_5(integer(), integer(), integer()) :: integer()
  @doc "Function doc 5 with 3 args"
  def func_5(input_1, input_2, input_3) do
    input_1 + input_2 + input_3
  end

  @spec func_6(String.t()) :: String.t()
  @doc "Function doc 6"
  def func_6("match" = input), do: input
  def func_6("matches" = input), do: input
  def func_6("matcher" = input), do: input
  def func_6("matching" = input), do: input
  def func_6(_), do: "no match"
end
