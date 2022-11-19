defmodule Doctor.DeriveProtocol do
  @moduledoc """
  An Example Derivation of a Protocol
  """

  @derive Inspect
  defstruct [:foo, :bar]
  @type t :: %__MODULE__{foo: String.t(), bar: non_neg_integer}
end
