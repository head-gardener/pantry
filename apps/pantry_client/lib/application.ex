defmodule PantryClient.Application do
  use Application

  @behaviour GenServer
  require Logger

  @moduledoc """
  Client for a pantry server.
  """

  @impl true
  def start(_type, args) do
    start_link(args)
  end

  def start_link(opts \\ [ui: :console, handle: :client]) do
    handle = Keyword.get(opts, :handle, :client)
    ui = Keyword.get(opts, :ui, :console)
    listener = Keyword.get(opts, :listener, nil)
    GenServer.start_link(__MODULE__, {ui, handle, listener})
  end

  def child(server, id) do
    GenServer.call(server, {:child, id})
  end

  defp get_ui_spec(:console, _) do
    %{
      id: UI,
      start: {PantryClient.UI.Console, :start_link, [self()]}
    }
  end

  defp get_ui_spec(:echo, listener) when is_pid(listener) do
    %{
      id: UI,
      start: {PantryClient.UI.Echo, :start_link, [listener]}
    }
  end

  defp get_ui_spec(:echo, listener) do
    Logger.error("Echo UI: listener should be PID, found #{inspect(listener)}")

    get_ui_spec(:console, nil)
  end

  defp get_ui_spec(ui, _) do
    Logger.error("Requested invalid UI: #{inspect(ui)}")

    get_ui_spec(:console, nil)
  end

  @impl true
  def init({ui, handle, listener}) do
    socket_spec = %{
      id: Socket,
      start: {PantryClient.Socket, :start_link, [self(), handle]}
    }

    ui_spec = get_ui_spec(ui, listener)

    {:ok, sup} = Supervisor.start_link([socket_spec, ui_spec], strategy: :one_for_one)
    {:ok, {sup}}
  end

  @impl true
  def handle_call({:child, id}, _from, {sup}) do
    {_, receiver, _, _} = Supervisor.which_children(sup) |> List.keyfind(id, 0)
    {:reply, receiver, {sup}}
  end
end
