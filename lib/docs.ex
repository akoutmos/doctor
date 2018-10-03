defmodule Doctor.Docs do
  @moduledoc """
  """

  alias __MODULE__

  defstruct ~w(kind name arity doc)a

  def build({{kind, name, arity}, _annotation, _signature, doc, _metadata}) do
    %Docs{
      kind: kind,
      name: name,
      arity: arity,
      doc: doc
    }
  end
end
