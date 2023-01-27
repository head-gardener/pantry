defmodule PantryServer.Application do
  use Application
  require Logger

  @moduledoc """
  Pantry server, does the actual work in a highly distributed manner.
  """

  @impl true
  def start(_type, args) do
    start_link(args)
  end

  def start_link(args \\ []) do
    client_handle = Keyword.get(args, :client_handle, :client)

    Supervisor.start_link(child_spec(client_handle), strategy: :one_for_one)
  end

  defp child_spec(client_handle) do
    [
      %{
        id: Manager,
        start: {PantryServer.Manager, :start_link, [self()]}
      },
      %{
        id: Socket,
        start: {PantryServer.Socket, :start_link, [self(), client_handle]}
      }
    ]
  end
end
