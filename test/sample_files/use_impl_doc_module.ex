defmodule Doctor.UseImplDocModule do
  @moduledoc """
  A module with a __using__ macro that injects GenServer callbacks with
  specs but without docs
  """
  defmacro __using__(_opts) do
    quote do
      use GenServer

      @impl GenServer
      @spec init(term()) :: {:ok, term()}
      def init(state), do: {:ok, state}

      @impl true
      @spec handle_call(term(), GenServer.from(), term()) :: {:reply, term(), term()}
      def handle_call(_request, _from, state), do: {:reply, state, state}
    end
  end
end
