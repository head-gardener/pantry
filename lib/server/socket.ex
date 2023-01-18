defmodule Pantry.Server.Socket do
  require Logger
  @behaviour GenServer

  @moduledoc """
  Connects server to the network. Main purpose is to isolate
  network-related errors from the server.
  """

  def start_link(parent, handle) do
    GenServer.start_link(__MODULE__, {parent, handle})
  end

  def request_state(server) do
    # TODO consider blocking the socket whenever server is pulling up the state
    # reason - socket might receive an outdated state and an update for it
    # if the socket broadcasts the update before sending out the state, the client
    # will end up with an outdated state
    GenServer.call(server, {:request_state})
  end

  def request_torrent_add(server, info) do
    GenServer.cast(server, {:request_torrent_add, info})
  end

  @spec send_state(GenServer.server(), GenServer.from(), Pantry.Server.State.state()) :: :ok
  def send_state(server, to, state) do
    GenServer.cast(server, {:send_state, to, state})
  end

  @doc """
  Sends `msg` to all processes registered as `:client` on all available nodes.
  Since only one process can register as a specific atom, this assumes at most 
  a single client on each node, which fits real life but may negatively impact 
  testing.
  """
  @spec broadcast(GenServer.server(), any) :: :ok
  def broadcast(server, msg) do
    GenServer.cast(server, {:broadcast, msg})
  end

  @impl true
  def init({parent, handle}) do
    Logger.debug("Server socket #{inspect(self())} initializing")
    {:ok, {parent, handle}}
  end

  @impl true
  def handle_call({:request_state}, from, {parent, handle}) do
    manager = Pantry.Server.Core.child(parent, Manager)
    Pantry.Server.Manager.request_state(manager, from)

    {:noreply, {parent, handle}}
  end

  @impl true
  def handle_cast({:request_torrent_add, info}, {parent, handle}) do
    manager = Pantry.Server.Core.child(parent, Manager)
    Pantry.Server.Manager.add(manager, info)

    {:noreply, {parent, handle}}
  end

  @impl true
  def handle_cast({:send_state, to, state}, {parent, handle}) do
    GenServer.reply(to, state)
    {:noreply, {parent, handle}}
  end

  @impl true
  def handle_cast({:broadcast, msg}, {parent, handle}) do
    Pantry.Client.Socket.broadcast(handle, msg, parent)

    {:noreply, {parent, handle}}
  end

  @impl true
  def handle_info(msg, {parent, handle}) do
    Logger.warning("Unexpected message in a server socket: #{msg}")
    {:noreply, {parent, handle}}
  end
end
