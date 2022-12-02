defmodule Pantry.Client.Socket do
  require Logger
  @behaviour GenServer

  @moduledoc """
  This module is responsible for linking UI with the router.
  It will crash if connection can't be established.
  After all, what is a client if not a UI and a socket.
  """

  def start_link(parent, handle) do
    GenServer.start_link(__MODULE__, {parent, handle})
  end

  def broadcast(handle, msg, from) do
    GenServer.abcast([Node.self() | Node.list()], handle, {:info, from, msg})
  end

  @impl true
  def init({parent, handle}) do
    try do
      Process.register(self(), handle)
    rescue
      e ->
        Logger.error(
          "Couldn't register the client, it will not receive data from servers. " <>
            "Is there a client already running in the current VM?\nError: #{inspect(e)}"
        )
    end

    Logger.info("Client socket #{inspect(self())} initializing")
    {:ok, {parent, []}}
  end

  @impl true
  def handle_cast({:info, from, msg}, {parent, servers}) when is_pid(from) do
    Logger.info("Socket received msg: #{inspect(msg)}")

    servers =
      if Enum.member?(servers, from) do
        agent = Pantry.Client.Core.child(parent, StateAgent)
        Pantry.Client.StateAgent.parse(agent, msg)
        servers
      else
        socket = Pantry.Server.Core.child(from, Socket)
        # TODO make this non blocking
        # reason: server might die during the request, 
        # which will result in a 5 second downtime
        state = Pantry.Server.Socket.request_state(socket)
        agent = Pantry.Client.Core.child(parent, StateAgent)
        Pantry.Client.StateAgent.join(agent, state)
        [from | servers]
      end

    agent = Pantry.Client.Core.child(parent, StateAgent)
    state = Pantry.Client.StateAgent.get(agent)
    ui = Pantry.Client.Core.child(parent, UI)
    Pantry.Client.UI.Console.display(ui, state)

    {:noreply, {parent, servers}}
  end

  @impl true
  def handle_cast(msg, {parent, servers}) do
    Logger.warning("Unexpected message: #{inspect(msg)}")
    {:noreply, {parent, servers}}
  end
end
