defmodule Doctor.OpaqueStructSpecModule do
  defstruct ~w(name arity)a

  @opaque t :: %__MODULE__{}
end
