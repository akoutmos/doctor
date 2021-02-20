defmodule Doctor.BehaviourModule do
  @moduledoc """
  This is a GenServer module that has 100% code coverage
  """

  use GenServer

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl GenServer
  @doc "Something or other"
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  def handle_call(:nop, _from, state) do
    {:reply, state}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end
