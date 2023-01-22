defmodule PantryServer.Application do
  use Application
  @behaviour GenServer

  @moduledoc """
  Pantry server, does the actual work in a highly distributed manner.
  """

  # TODO this shouldn't be genserver

  @impl true
  def start(_type, args) do
    start_link(args)
  end

  def start_link(args \\ [handle: :client]) do
    handle = Keyword.get(args, :handle, :client)

    GenServer.start_link(__MODULE__, handle)
  end

  def child(server, id) do
    GenServer.call(server, {:child, id})
  end

  @impl true
  def init(handle) do
    manager_spec = %{
      id: Manager,
      start: {PantryServer.Manager, :start_link, [self()]}
    }

    socket_spec = %{
      id: Socket,
      start: {PantryServer.Socket, :start_link, [self(), handle]}
    }

    {:ok, sup} = Supervisor.start_link([manager_spec, socket_spec], strategy: :one_for_one)

    {_, socket, _, _} = Supervisor.which_children(sup) |> List.keyfind(Socket, 0)
    # inform all listening client sockets of a new server,
    # which triggers discovery sequence
    PantryServer.Socket.broadcast(socket, {:server_spawned})

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
