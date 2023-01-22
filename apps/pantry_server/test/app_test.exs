defmodule PantryServer.AppTest do
  use ExUnit.Case, async: true
  alias PantryServer.Application, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    {:ok, server} = Subject.start_link()
    [server: server]
  end

  test "state", context do
    socket = Subject.child(context.server, Socket)
    pure = PantryServer.State.pure(context.server)
    ^pure = PantryServer.Socket.request_state(socket)
  end
end
