defmodule Pantry.Router do
  @behaviour GenServer

  def start() do
    GenServer.start(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_info({:added_torrent, data}, state) do
    IO.puts("added #{data}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:port_started}, state) do
    IO.puts("started engine port")
    {:noreply, state}
  end

  @impl true
  def handle_info({:port_critical, msg}, state) do
    IO.puts("(CRIT) #{msg}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:port_warning, msg}, state) do
    IO.puts("(WARN) #{msg}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:port_exit, code}, state) do
    IO.puts("engine port closed with #{code} exit code.")
    {:noreply, state}
  end

  @impl true
  def handle_info(x, state) do
    IO.puts("unexpected message #{inspect(x)}")
    {:noreply, state}
  end
end
