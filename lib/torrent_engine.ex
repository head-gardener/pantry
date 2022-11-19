defmodule Pantry.TorrentEngine do
  @behaviour GenServer

  def start() do
    GenServer.start(__MODULE__, :ok)
  end

  def close(server) do
    GenServer.call(server, {:close})
  end

  def add(server, file) do
    GenServer.call(server, {:add, file})
  end

  @impl true
  def init(:ok) do
    opts = [{:packet, 4}, :binary, :exit_status, :use_stdio]
    port = Port.open({:spawn, "native/torrent_engine/bin/torrent_engine"}, opts)

    receive do
      {^port, {:data, "(2) hi"}} -> {:ok, port}
      x -> "unexpected responce #{inspect(x)}"
    after
      1_000 -> "port didn't respond"
    end
  end

  @impl true
  def handle_call({:close}, _from, port) do
    {:reply, Port.close(port), port}
  end

  @impl true
  def handle_call({:add, file}, _from, port) do
    true = Port.command(port, "add " <> file)

    {:reply, 1, port}
  end

  @impl true
  def handle_info(val, port) do
    case val do
      {^port, {:data, data}} -> {:noreply, handle_data(data, port)}
      x -> "unexpected responce #{inspect(x)}"
    end
  end

  defp handle_data(data, port) do
    IO.puts("received #{data}")
    send(self(), {:added, data})
    port
  end
end
