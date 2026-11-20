defmodule Doctor.TypeAndFunctionSameName do
  @moduledoc """
  A module with a public type and a public function that share the same
  name and arity, both without docs
  """
  @type action :: atom()
  def action, do: :index
end
