defmodule PantryServer.SocketTest do
  use ExUnit.Case, async: true
  alias PantryServer.Socket, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    {:ok, socket} = Subject.start_link(self(), :socket_test)

    [socket: socket]
  end

  test "blink", context do
    Process.register(self(), :socket_test)
    subject = context.socket

    Subject.schedule_blink(subject, loop: false, delay: 0)
    assert_receive {_, {:info, ^subject, {:blink}}}
  end
end
