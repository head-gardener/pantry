defmodule PantryClient.UI.Echo do
  @behaviour GenServer

  @moduledoc """
  Echoing UI for testing.
  """

  def start_link(listener) do
    GenServer.start_link(__MODULE__, listener)
  end

  @impl true
  def init(listener) do
    {:ok, {listener}}
  end

  @impl true
  def handle_cast({:display, state}, {listener}) do
    send(listener, {:echo, state})

    {:noreply, {listener}}
  end
end
