defmodule PantryClient.Socket do
  require Logger
  @behaviour GenServer

  alias PantryServer.State
  alias PantryClient.Application

  @moduledoc """
  This module is responsible for linking UI with the router.
  It will crash if connection can't be established.
  After all, what is a client if not a UI and a socket.
  """

  def start_link(parent, handle) do
    GenServer.start_link(__MODULE__, {parent, handle})
  end

  def get_state(handle) do
    GenServer.call(handle, :get_state)
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

    Logger.debug("Client socket #{inspect(self())} initializing")
    {:ok, {parent, State.pure()}}
  end

  @impl true
  def handle_call(:get_state, _, {parent, state}) do
    {:reply, state, {parent, state}}
  end

  @impl true
  def handle_cast({:info, from, msg}, {parent, state}) when is_pid(from) do
    Logger.debug("Client socket received info: #{inspect(msg)}")

    state =
      if State.knows?(state, from) do
        {_, new_state} = State.parse(state, msg)
        new_state
      else
        Logger.debug(
          "Discovery sequence triggered for #{inspect(from)} after receiving #{inspect(msg)}"
        )

        # TODO make this non blocking
        # reason: server might die during the request, 
        # which will result in a 5 second downtime
        Application.child(from, Socket)
        |> PantryServer.Socket.request_state()
        |> State.join(state)
      end

    Application.child(parent, UI)
    |> PantryClient.UI.Generic.display(state)

    {:noreply, {parent, state}}
  end

  @impl true
  def handle_cast(msg, {parent, servers}) do
    Logger.warning("Client socket received unexpected message: #{inspect(msg)}")
    {:noreply, {parent, servers}}
  end
end
