defmodule Pantry.Server.Core do
  @behaviour GenServer

  @moduledoc """
  Responsible for supervision of all subsystems in a single atomic cluster, 
  i. e. controls a single manager (more subjects will be added over time).
  """

  def start_link(handle \\ :client) do
    GenServer.start_link(__MODULE__, handle)
  end

  def child(server, id) do
    GenServer.call(server, {:child, id})
  end

  @impl true
  def init(handle) do
    manager_spec = %{
      id: Manager,
      start: {Pantry.Server.Manager, :start_link, [self()]}
    }

    socket_spec = %{
      id: Socket,
      start: {Pantry.Server.Socket, :start_link, [self(), handle]}
    }

    {:ok, sup} = Supervisor.start_link([manager_spec, socket_spec], strategy: :one_for_one)

    {_, socket, _, _} = Supervisor.which_children(sup) |> List.keyfind(Socket, 0)
    # inform all listening client sockets of a new server,
    # which triggers discovery sequence
    Pantry.Server.Socket.broadcast(socket, {:server_spawned})

    {:ok, {sup}}
  end

  @impl true
  def handle_call({:child, id}, _from, {sup}) do
    child = get_child(sup, id)
    {:reply, child, {sup}}
  end

  @impl true
  def handle_info(msg, {sup}) do
    socket = get_child(sup, Socket)
    send(socket, msg)

    {:noreply, sup}
  end

  defp get_child(sup, id) do
    {_, child, _, _} = Supervisor.which_children(sup) |> List.keyfind(id, 0)
    child
  end
end
