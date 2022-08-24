defmodule Doctor.ImplementProtocol do
  @moduledoc """
  An Example Implementation of a Protocol
  """

  defstruct [:foo, :bar]
  @type t :: %__MODULE__{foo: String.t(), bar: non_neg_integer}

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(struct, opts) do
      doc = struct |> Map.from_struct() |> Map.to_list() |> to_doc(opts)

      concat(["#ExampleDefImpl<", doc, ">"])
    end
  end
end
