defmodule Pantry.Server.CoreTest do
  use ExUnit.Case, async: true
  alias Pantry.Server.Core, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    {:ok, server} = Subject.start_link()
    [server: server]
  end

  test "state", context do
    socket = Subject.child(context.server, Socket)
    pure = Pantry.Server.State.pure()
    ^pure = Pantry.Server.Socket.request_state(socket)
  end
end
