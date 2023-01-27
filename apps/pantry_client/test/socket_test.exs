defmodule PantryClient.SocketTest do
  use ExUnit.Case, async: true
  alias PantryClient.Socket, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    {:ok, socket} = Subject.start_link(self())

    [socket: socket]
  end

  test "state", context do
    pure = PantryServer.State.pure()
    assert ^pure = PantryClient.Socket.get_state(context.socket)
  end

  # test "blinks", context do
  #   socket = context.socket
  #   state = PantryServer.State.pure(self())

  #   GenServer.cast(socket, {:info, self(), {:blink}})
  #   assert_receive {_, {socket, _} = ref, {:request_state}}, 100
    # GenServer.reply(ref, state)
    
    # requests socket
    # assert_receive {_, {socket, _} = ref, {_}}, 100
    # GenServer.reply(ref, [manager: {_, receiver, _, _}])
  # end
end
