defmodule Doctor.ParentModule do
  @moduledoc """
  A module containing another module
  """

  defmodule Nested do
    @moduledoc """
    A nested module
    """

    @doc """
    A function in the nested module
    """
    @spec inner :: :ok
    def inner, do: :ok
  end

  @doc """
  A function in the outer module
  """
  @spec outer :: :ok
  def outer, do: :ok
end
