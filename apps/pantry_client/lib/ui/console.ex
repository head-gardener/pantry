defmodule PantryClient.UI.Console do
  @behaviour GenServer

  @moduledoc """
  TUI for pantry client.
  """

  def start_link(parent) do
    GenServer.start_link(__MODULE__, parent)
  end

  @impl true
  def init(parent) do
    {:ok, {parent}}
  end

  @impl true
  def handle_cast({:display, state}, {parent}) do
    torrents =
      PantryServer.State.map(state, fn {ts, _} ->
        Enum.map(ts, &("torrent: " <> &1))
      end)

    servers =
      PantryServer.State.map(state, fn {_, ss} ->
        Enum.map(ss, &"server: #{inspect(&1)}")
      end)

    for torrent <- torrents do
      IO.puts(torrent)
    end

    for server <- servers do
      IO.puts(server)
    end

    {:noreply, {parent}}
  end
end
