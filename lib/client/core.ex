defmodule Pantry.Client.Core do
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
    socket_spec = %{
      id: Socket,
      start: {Pantry.Client.Socket, :start_link, [self(), handle]}
    }
    ui_spec = %{
      id: UI,
      start: {Pantry.Client.UI.Console, :start_link, [self()]}
    }

    {:ok, sup} = Supervisor.start_link([socket_spec, ui_spec], strategy: :one_for_one)
    {:ok, {sup}}
  end

  @impl true
  def handle_call({:child, id}, _from, {sup}) do
    {_, receiver, _, _} = Supervisor.which_children(sup) |> List.keyfind(id, 0)
    {:reply, receiver, {sup}}
  end
end
