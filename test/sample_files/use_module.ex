defmodule Doctor.UseModule do
  @moduledoc """
  A module with __using__ macro
  """
  defmacro __using__(_opts) do
    quote do
      @doc """
      Returns :ok
      """
      @spec fun_with_doc_and_spec() :: :ok
      def fun_with_doc_and_spec, do: :ok

      @doc """
      Sample function
      """
      def fun_with_doc, do: :ok

      @spec fun_with_spec() :: :ok
      def fun_with_spec, do: :ok

      def fun_without_spec_and_doc, do: :ok
    end
  end
end
