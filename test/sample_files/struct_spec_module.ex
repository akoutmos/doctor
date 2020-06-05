defmodule Doctor.StructSpecModule do
  @type t :: %__MODULE__{
          name: atom(),
          arity: integer()
        }

  defstruct ~w(name arity)a
end
