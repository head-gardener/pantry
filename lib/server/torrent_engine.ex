defmodule Pantry.Server.TorrentEngine do
  @behaviour GenServer
  require Logger

  @moduledoc """
  Wraps around an engine port and provides an asynchronous functional interface.
  """

  def start_link(parent) do
    GenServer.start_link(__MODULE__, parent)
  end

  def add(server, file) do
    GenServer.cast(server, {:add, file})
  end

  def state(server) do
    GenServer.call(server, {:state})
  end

  @impl true
  def terminate(reason, {port, _, _}) do
    # so ugh it's critical to validate that this callback is
    # called exactly the way I assume it is - in order to avoid
    # considerable resource leakage
    Logger.debug("Port #{inspect(self())} terminating")

    if nil != Port.info(port) do
      true = Port.close(port)
    end

    reason
  end

  @impl true
  def init(parent) do
    Process.flag(:trap_exit, true)

    opts = [{:packet, 4}, :binary, :exit_status, :use_stdio]
    port = Port.open({:spawn, "native/torrent_engine/bin/torrent_engine"}, opts)
    state = Pantry.Server.State.pure()

    Logger.debug("Port #{inspect(self())} inits")
    {:ok, {port, parent, state}}
  end

  @impl true
  def handle_cast({:add, file}, {port, parent, state}) do
    true = Port.command(port, "add " <> ~s[{"save_path":".","torrent_info":"#{file}"}])
    Logger.debug("#{inspect(self())} adding...")

    {:noreply, {port, parent, state}}
  end

  @impl true
  def handle_call({:state}, _from, {port, parent, state}) do
    {:reply, state, {port, parent, state}}
  end

  @impl true
  def handle_info({_port, {:data, "(0) " <> msg}}, {port, parent, state}) do
    send(parent, {:port_critical, msg})
    {:noreply, {port, parent, state}}
  end

  @impl true
  def handle_info({_port, {:data, "(1) " <> msg}}, {port, parent, state}) do
    send(parent, {:port_warning, msg})
    {:noreply, {port, parent, state}}
  end

  @impl true
  def handle_info({_port, {:data, "(2) added " <> id}}, {port, parent, state}) do
    # Logger.debug("#{inspect(self())} added")

    msg = {:added_torrent, id}
    {:ok, state} = Pantry.Server.State.parse(state, msg)
    send(parent, msg)

    {:noreply, {port, parent, state}}
  end

  @impl true
  def handle_info({_port, {:data, "(2) started"}}, {port, parent, state}) do
    send(parent, {:port_started})
    {:noreply, {port, parent, state}}
  end

  @impl true
  def handle_info({_port, {:data, msg}}, {port, parent, state}) do
    Logger.debug("#{inspect(self())} unexpected log from port #{msg}")
    {:noreply, {port, parent, state}}
  end

  @impl true
  def handle_info({_port, {:exit_status, code}}, {port, parent, state}) do
    Logger.debug("#{inspect(self())} soldier down")
    send(parent, {:port_exit, code})
    {:noreply, {port, parent, state}}
  end

  @impl true
  def handle_info({:EXIT, port, reason}, {port, parent, state}) do
    Logger.debug("port exit caught")
    {:stop, reason, {port, parent, state}}
  end

  @impl true
  def handle_info({:EXIT, parent, reason}, {port, parent, state}) do
    Logger.debug("parent exit caught")
    {:stop, reason, {port, parent, state}}
  end

  @impl true
  def handle_info(val, {port, parent, state}) do
    Logger.debug("#{inspect(self())} unexpected port responce #{inspect(val)}")
    {:noreply, {port, parent, state}}
  end
end
