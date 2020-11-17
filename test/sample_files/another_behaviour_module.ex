defmodule Doctor.AnotherBehaviourModule.Behaviour do
  @callback func() :: String.t()
end

defmodule Doctor.AnotherBehaviourModule do
  @behaviour Doctor.AnotherBehaviourModule.Behaviour

  @impl Doctor.AnotherBehaviourModule.Behaviour
  def func, do: "Hello world"
end
