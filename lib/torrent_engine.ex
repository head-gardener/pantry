defmodule Pantry.TorrentEngine do
  @behaviour GenServer

  def start() do
    GenServer.start(__MODULE__, :ok)
  end

  def close(server) do
    GenServer.call(server, {:close})
  end

  def add(server, file) do
    GenServer.cast(server, {:add, file})
  end

  @impl true
  def init(:ok) do
    opts = [{:packet, 4}, :binary, :exit_status, :use_stdio]
    port = Port.open({:spawn, "native/torrent_engine/bin/torrent_engine"}, opts)

    #     receive do
    #       {^port, {:data, "(2) hi"}} -> {:ok, port}
    #     after
    #       1_000 -> "port didn't respond"
    #     end
    {:ok, port}
  end

  @impl true
  def handle_call({:close}, _from, port) do
    IO.puts("closing...")
    {:reply, Port.close(port), port}
  end

  @impl true
  def handle_cast({:add, file}, state) do
    true = Port.command(state, "add " <> file)

    {:noreply, state}
  end

  @impl true
  def handle_info({_port, {:data, "(0) " <> msg}}, state) do
    send(:router, {:port_critical, msg})
    {:noreply, state}
  end

  @impl true
  def handle_info({_port, {:data, "(1) " <> msg}}, state) do
    send(:router, {:port_warning, msg})
    {:noreply, state}
  end

  @impl true
  def handle_info({_port, {:data, "(2) added " <> id}}, state) do
    send(:router, {:added_torrent, id})
    {:noreply, state}
  end

  @impl true
  def handle_info({_port, {:data, "(2) hi"}}, state) do
    send(:router, {:port_started})
    {:noreply, state}
  end

  @impl true
  def handle_info({_port, {:data, msg}}, state) do
    IO.puts("unexpected log from port #{msg}")
    {:noreply, state}
  end

  @impl true
  def handle_info({_port, {:exit_status, code}}, _state) do
    send(:router, {:port_exit, code})
    {:ok, port} = init(:ok)
    {:noreply, port}
  end

  @impl true
  def handle_info(val, state) do
    IO.puts("unexpected port responce #{inspect(val)}")
    {:noreply, state}
  end
end
