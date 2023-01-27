defmodule PantryClient.Application do
  use Application
  require Logger

  @moduledoc """
  Client for a pantry server.
  """

  @impl true
  def start(_type, args) do
    start_link(args)
  end

  def start_link(opts \\ []) do
    handle = Keyword.get(opts, :handle, :client)
    ui = Keyword.get(opts, :ui, :console)
    listener = Keyword.get(opts, :listener, nil)

    socket_spec = %{
      id: Socket,
      start: {PantryClient.Socket, :start_link, [self(), handle]}
    }

    Supervisor.start_link([socket_spec, ui_spec(ui, listener)], strategy: :one_for_one)
  end

  def child(server, id) do
    {_, receiver, _, _} = Supervisor.which_children(server) |> List.keyfind(id, 0)
    receiver
  end

  defp ui_spec(:console, _),
    do: %{id: UI, start: {PantryClient.UI.Console, :start_link, [self()]}}

  defp ui_spec(:echo, listener) when is_pid(listener),
    do: %{id: UI, start: {PantryClient.UI.Echo, :start_link, [listener]}}

  defp ui_spec(:echo, listener) do
    Logger.error("Echo UI: listener should be PID, found #{inspect(listener)}")
    ui_spec(:console, nil)
  end

  defp ui_spec(ui, _) do
    Logger.error("Requested invalid UI: #{inspect(ui)}")
    ui_spec(:console, nil)
  end
end
