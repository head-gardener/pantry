defmodule Pantry.Client.CoreTest do
  use ExUnit.Case, async: true
  alias Pantry.Client.Core, as: Subject
  doctest Subject

  setup [:start_client, :start_server]

  defp start_client(_context) do
    # generates unique handle for each test to avoid broadcast clashes
    handle = String.to_atom(inspect(make_ref()))
    {:ok, client} = Subject.start_link(handle)
    [client: client, handle: handle]
  end

  defp start_server(context) do
    {:ok, server} = Pantry.Server.Core.start_link(context.handle)
    {:ok, server: server}
  end

  test "registers new processes correctly", context do
    msg = {:added_torrent, 0}
    {:ok, state} = Pantry.Server.State.pure() |> Pantry.Server.State.parse(msg)

    socket = Subject.child(context.client, Socket)
    GenServer.cast(socket, {:info, context.server, msg})

    :ok =
      receive do
        x -> x
      after
        100 -> :ok
      end

    agent = Subject.child(context.client, StateAgent)
    assert ^state = Pantry.Client.StateAgent.get(agent)
  end

  test "event broadcasts work", context do
    socket = Pantry.Server.Core.child(context.server, Socket)
    Pantry.Server.Socket.request_torrent_add(socket, %{file: "examples/nmap.torrent"})

    :ok =
      receive do
        x -> x
      after
        100 -> :ok
      end

    agent = Subject.child(context.client, StateAgent)
    %{torrents: ts} = Pantry.Client.StateAgent.get(agent)
    assert Enum.count(ts) == 1
  end
end
