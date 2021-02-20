defmodule Doctor.FooBarBehaviour do
  @moduledoc """
  A custom behaviour module
  """

  @doc """
  The famous foo function
  """
  @callback foo(mode :: atom()) :: integer()

  @doc """
  And the infamous bar function
  """
  @callback bar(mode :: atom()) :: integer()

  @callback bar(mode :: atom(), param :: integer()) :: integer()
end

defmodule Doctor.FooBar do
  @moduledoc """
  Implementation of the FooBarBehaviour
  """

  @behaviour Doctor.FooBarBehaviour

  def foo(:five), do: 5

  # This should not
  @impl true
  def foo(:one), do: 1

  # neither this
  def foo(:two), do: 2

  @impl Doctor.FooBarBehaviour
  def bar(:one), do: 1
  def bar(:two), do: 2
  def bar(:three), do: 3

  # This should raise both a missing spec and a missing doc
  def bar(:test, value), do: value

  # This should pass
  @impl Doctor.FooBarBehaviour
  def bar(:bar, value), do: value

  # This should raise both a missing doc and spec
  def bar(:noop, _value1, _value2), do: 0
end
