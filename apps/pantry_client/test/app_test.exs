defmodule PantryClient.AppTest do
  use ExUnit.Case, async: true
  alias PantryClient.Application, as: Subject
  alias PantryServer.Application, as: Server
  doctest Subject

  setup [:start_client, :start_server]

  defp start_client(_context) do
    # generate unique handle for each test to avoid broadcast clashes
    handle = String.to_atom(inspect(make_ref()))
    {:ok, client} = Subject.start_link(handle: handle, ui: :echo, listener: self())
    [client: client, handle: handle]
  end

  defp start_server(context) do
    {:ok, server} = Server.start_link(handle: context.handle)
    {:ok, server: server}
  end

  test "registers new servers correctly", context do
    msg = {:added_torrent, "0"}
    {:ok, state} = PantryServer.State.pure(context.server) |> PantryServer.State.parse(msg)

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

    assert ^state = PantryClient.Socket.get_state(socket)
  end

  test "server side event broadcasts work", context do
    socket = Server.child(context.server, Socket)
    server = context.server
    PantryServer.Socket.request_torrent_add(socket, %{file: "../../contrib/nmap.torrent"})

    :ok =
      receive do
        # x -> x
      after
        100 -> :ok
      end

    socket = Subject.child(context.client, Socket)
    %{torrents: ts, servers: [^server]} = PantryClient.Socket.get_state(socket)
    assert Enum.count(ts) == 1
  end
end
