defmodule Doctor.Specs do
  @moduledoc """
  This module defines a struct which houses all the
  documentation data for function specs.
  """

  alias __MODULE__

  defstruct ~w(name arity)a

  @doc """
  Build a spec definition for each result from Code.Typespec.fetch_specs/1
  """
  def build({{name, arity}, _spec}) do
    %Specs{
      name: name,
      arity: arity
    }
  end
end
