defmodule Pantry.Client.CoreTest do
  use ExUnit.Case, async: false
  alias Pantry.Client.Core, as: Subject
  doctest Subject

  setup [:start_client, :start_server]

  defp start_client(_context) do
    # generate unique handle for each test to avoid broadcast clashes
    handle = String.to_atom(inspect(make_ref()))
    {:ok, client} = Subject.start_link(handle: handle, ui: :echo, listener: self())
    [client: client, handle: handle]
  end

  defp start_server(context) do
    {:ok, server} = Pantry.Server.Core.start_link(context.handle)
    {:ok, server: server}
  end

  test "registers new servers correctly", context do
    msg = {:added_torrent, "0"}
    {:ok, state} = Pantry.Server.State.pure(context.server) |> Pantry.Server.State.parse(msg)

    # wait for server to intialize and register
    :ok =
      receive do
        # x -> x
      after
        100 -> :ok
      end

    socket = Subject.child(context.client, Socket)
    GenServer.cast(socket, {:info, context.server, msg})

    :ok =
      receive do
        # x -> x
      after
        100 -> :ok
      end

    assert ^state = Pantry.Client.Socket.get_state(socket)
  end

  test "server side event broadcasts work", context do
    socket = Pantry.Server.Core.child(context.server, Socket)
    server = context.server
    Pantry.Server.Socket.request_torrent_add(socket, %{file: "examples/nmap.torrent"})

    :ok =
      receive do
        # x -> x
      after
        100 -> :ok
      end

    socket = Subject.child(context.client, Socket)
    %{torrents: ts, servers: [^server]} = Pantry.Client.Socket.get_state(socket)
    assert Enum.count(ts) == 1
  end
end
