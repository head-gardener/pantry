defmodule PantryServer.Manager do
  require Logger
  @behaviour GenServer

  alias PantryServer.TorrentEngine, as: Engine
  alias PantryServer.Application

  @moduledoc """
  If TorrentEngine is a lousy worker, this module is a somewhat sensible overseer.
  It solves the problem of sorting the onslaught of messages, providing supervision
  and possibly introducing multiple worker threads.
  """

  def start_link(parent) do
    GenServer.start_link(__MODULE__, parent)
  end

  def add(server, info) do
    GenServer.cast(server, {:add, info})
  end

  def request_state(server, to) do
    GenServer.cast(server, {:state, to})
  end

  @impl true
  def terminate(reason, _) do
    Logger.debug("Manager exited with reason: #{inspect(reason)}")

    reason
  end

  @impl true
  def init(parent) do
    Process.flag(:trap_exit, true)
    Logger.debug("Manager #{inspect(self())} initialized")

    child = %{
      id: Engine,
      start: {Engine, :start_link, [self()]}
    }

    {:ok, sup} = Supervisor.start_link([child], strategy: :one_for_one)
    {:ok, {parent, sup}}
  end

  @impl true
  def handle_info({:port_started}, {parent, sup}) do
    Logger.debug("Port #{inspect(self())} initialized")

    {:noreply, {parent, sup}}
  end

  @impl true
  def handle_info({:added_torrent, id}, {parent, sup}) do
    Logger.debug("Added torrent #{id}")

    socket = Application.child(parent, Socket)
    PantryServer.Socket.broadcast(socket, {:added_torrent, id})

    {:noreply, {parent, sup}}
  end

  @impl true
  def handle_info({:port_critical, msg}, {parent, sup}) do
    Logger.error(msg)

    {:noreply, {parent, sup}}
  end

  @impl true
  def handle_info(x, {parent, sup}) do
    Logger.warning("Port manager received unexpected message #{inspect(x)}")

    {:noreply, {parent, sup}}
  end

  @impl true
  def handle_cast({:add, %{file: file}}, {parent, sup}) do
    [{_, worker, _, _}] = Supervisor.which_children(sup)
    Engine.add(worker, file)

    {:noreply, {parent, sup}}
  end

  @impl true
  def handle_cast({:state, to}, {parent, sup}) do
    # collect state and add the server to it
    state =
      Supervisor.which_children(sup)
      |> Enum.map(fn {_, worker, _, _} ->
        Engine.state(worker)
      end)
      |> Enum.reduce(PantryServer.State.pure(parent), &PantryServer.State.join/2)

    socket = Application.child(parent, Socket)
    PantryServer.Socket.send_state(socket, to, state)

    {:noreply, {parent, sup}}
  end
end
