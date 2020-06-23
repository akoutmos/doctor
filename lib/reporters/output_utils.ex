defmodule Doctor.Reporters.OutputUtils do
  @moduledoc """
  This module provides convenience functions for use when generating
  reports
  """

  alias Elixir.IO.ANSI

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

  @doc """
  Prints a divider of a given length
  """
  def print_divider(length) do
    "-"
    |> String.duplicate(length)
    |> Mix.shell().info()
  end

  @doc """
  Prints a checkmark of an X if true of false is provided respectively
  """
  def print_pass_or_fail(true), do: "\u2713"
  def print_pass_or_fail(false), do: "\u2717"
  def print_pass_or_fail(:not_struct), do: "N/A"

  @doc """
  Prints a string in red
  """
  def print_error(string), do: Mix.shell().info(ANSI.red() <> string <> ANSI.reset())

  @doc """
  Prints a string in green
  """
  def print_success(string), do: Mix.shell().info(ANSI.green() <> string <> ANSI.reset())

  @doc """
  Generate a string with a configure amount of width and padding
  """
  def gen_fixed_width_string(value, width, padding \\ 2)

  def gen_fixed_width_string(value, width, padding) when is_atom(value) do
    value
    |> Atom.to_string()
    |> gen_fixed_width_string(width, padding)
  end

  def gen_fixed_width_string(value, width, padding) when is_integer(value) do
    value
    |> Integer.to_string()
    |> gen_fixed_width_string(width, padding)
  end

  def gen_fixed_width_string(value, width, padding) do
    sub_string_length = width - (padding + 1)

    value
    |> String.slice(0..sub_string_length)
    |> String.pad_trailing(width)
  end
end
