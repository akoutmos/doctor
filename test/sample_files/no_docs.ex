defmodule Doctor.NoDocs do
  def func_1(input) do
    input + 1
  end

  def func_2(input), do: input + 2

  def func_3(input) when is_integer(input) do
    input + 3
  end

  def func_4(input) when is_integer(input), do: input + 4

  def func_5(input_1, input_2) do
    func_5(input_1, input_2, 5)
  end

  def func_5(input_1, input_2, input_3) do
    input_1 + input_2 + input_3
  end

  def func_6("match" = input), do: input
  def func_6("matches" = input), do: input
  def func_6("matcher" = input), do: input
  def func_6("matching" = input), do: input
  def func_6(_), do: "no match"
end
