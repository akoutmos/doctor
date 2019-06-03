defmodule Doctor.Reporters.OutputUtils do
  @moduledoc """
  This module provides convenience functions for use when generating
  reports
  """

  @doc """
  Generate a line in a table with the given width and padding. Expects a
  list with either a 2 or 3 element tuple.
  """
  def generate_table_line(line_data) do
    line_data
    |> Enum.reduce("", fn
      {value, width}, acc ->
        "#{acc}#{gen_fixed_width_string(value, width)}"

      {value, width, padding}, acc ->
        "#{acc}#{gen_fixed_width_string(value, width, padding)}"
    end)
  end

  defp gen_fixed_width_string(value, width, padding \\ 2)

  defp gen_fixed_width_string(value, width, padding) when is_integer(value) do
    value
    |> Integer.to_string()
    |> gen_fixed_width_string(width, padding)
  end

  defp gen_fixed_width_string(value, width, padding) do
    sub_string_length = width - (padding + 1)

    value
    |> String.slice(0..sub_string_length)
    |> String.pad_trailing(width)
  end
end
