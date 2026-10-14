defmodule Doctor.UseImplSpecModule do
  @moduledoc """
  A module with a __using__ macro that injects documented GenServer callbacks
  without specs
  """
  defmacro __using__(_opts) do
    quote do
      use GenServer

      @doc """
      Initializes the state
      """
      @impl GenServer
      def init(state), do: {:ok, state}

      @doc """
      Replies with the state
      """
      @impl true
      def handle_call(_request, _from, state), do: {:reply, state, state}
    end
  end
end
