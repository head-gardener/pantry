defmodule PantryServer.Socket do
  require Logger
  @behaviour GenServer

  @blick_delay 5000

  @moduledoc """
  Connects server to the network. Main purpose is to isolate
  network-related errors from the server.
  """

  def start_link(parent, client_handle \\ :client) do
    GenServer.start_link(__MODULE__, {parent, client_handle})
    # GenServer.start_link(__MODULE__, {parent, client_handle}, name: :server_socket)
  end

  def request_state(server) do
    # TODO consider blocking the socket whenever server is pulling up the state
    # reason - socket might receive an outdated state and an update for it
    # if the socket broadcasts the update before sending out the state, the client
    # will end up with an outdated state
    GenServer.call(server, {:request_state})
  end

  @doc """
  Sends torrent request to an associated manager
  """
  def request_torrent_add(server, info) do
    GenServer.cast(server, {:request_torrent_add, info})
  end

  @doc """
  Schedules a bcast to inform all new and listening clients that server is up.
  """
  def schedule_blink(server, opts \\ []) do
    delay = Keyword.get(opts, :delay, @blick_delay)
    loop = Keyword.get(opts, :loop, true)

    Process.send_after(server, {:blink_request, loop, delay}, delay)
  end

  @doc """
  Request the socket to send `msg` to all processes registered as `:client` on 
  all available nodes.
  Since only one process can register as a specific atom, this assumes at most 
  a single client on each node, which fits real life but may negatively impact 
  testing.
  """
  @spec broadcast(GenServer.server(), any) :: :ok
  def broadcast(server, msg) do
    GenServer.cast(server, {:broadcast, msg})
  end

  @impl true
  def init({parent, client_handle}) do
    Logger.debug("Server socket #{inspect(self())} initializing")
    Process.register(self(), :server_socket)
    schedule_blink(self())
    {:ok, {parent, client_handle}}
  end

  @impl true
  def handle_call({:request_state}, from, {parent, client_handle}) do
    PantryServer.Manager.request_state(:manager, from)

    {:noreply, {parent, client_handle}}
  end

  @impl true
  def handle_cast({:request_torrent_add, info}, {parent, client_handle}) do
    PantryServer.Manager.add(:manager, info)

    {:noreply, {parent, client_handle}}
  end

  @impl true
  def handle_cast({:broadcast, msg}, {parent, client_handle}) do
    GenServer.abcast([Node.self() | Node.list()], client_handle, {:info, self(), msg})

    {:noreply, {parent, client_handle}}
  end

  @impl true
  def handle_info({:blink_request, true, delay}, {parent, client_handle}) do
    broadcast_to_clients(client_handle, {:blink})
    schedule_blink(self(), delay: delay, loop: true)

    {:noreply, {parent, client_handle}}
  end

  @impl true
  def handle_info({:blink_request, false, _}, {parent, client_handle}) do
    broadcast_to_clients(client_handle, {:blink})

    {:noreply, {parent, client_handle}}
  end

  @impl true
  def handle_info(msg, {parent, client_handle}) do
    Logger.warning("Unexpected message in a server socket: #{inspect(msg)}")
    {:noreply, {parent, client_handle}}
  end

  # Send `msg` to all clients, registered as `handle`.
  defp broadcast_to_clients(client_handle, msg) do
    GenServer.abcast([Node.self() | Node.list()], client_handle, {:info, self(), msg})
  end
end
