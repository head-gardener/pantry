defmodule PantryServer.AppTest do
  use ExUnit.Case, async: true
  alias PantryServer.Application, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    # wait for namespace to clear
    refute_receive nil, 100
    {:ok, server} = Subject.start_link()
    [server: server]
  end

  test "state", _context do
    socket = Process.whereis(:server_socket)
    pure = PantryServer.State.pure(socket)
    ^pure = PantryServer.Socket.request_state(socket)
  end
end
