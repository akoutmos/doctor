defmodule Doctor.Specs do
  @moduledoc """
  """

  alias __MODULE__

  defstruct ~w(name arity)a

  def build({{name, arity}, _spec}) do
    %Specs{
      name: name,
      arity: arity
    }
  end
end
