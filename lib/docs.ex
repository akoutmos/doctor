defmodule Doctor.Docs do
  @moduledoc """
  This module defines a struct which houses all the
  documentation data for module functions.
  """

  alias __MODULE__

  defstruct ~w(kind name arity doc)a

  @doc """
  Build the Docs struct from the results of Code.fetch_docs/0
  """
  def build({{kind, name, arity}, _annotation, _signature, doc, _metadata}) do
    %Docs{
      kind: kind,
      name: name,
      arity: arity,
      doc: doc
    }
  end
end
