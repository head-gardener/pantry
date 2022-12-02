defmodule Pantry.Client.UI.Console do
  @behaviour GenServer

  def start_link(parent) do
    GenServer.start_link(__MODULE__, [parent])
  end

  def display(server, state) do
    GenServer.cast(server, {:display, state})
  end

  @impl true
  def init(parent) do
    {:ok, {parent}}
  end

  @impl true
  def handle_cast({:display, state}, {parent}) do
    torrents = state.torrents |> Enum.map(fn id -> "torrent: " <> id end)

    for torrent <- torrents do
      IO.puts(torrent)
    end

    {:noreply, {parent}}
  end
end
