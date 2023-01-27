defmodule PantryClient.AppTest do
  use ExUnit.Case, async: false
  alias PantryClient.Application, as: Subject
  alias PantryServer.Application, as: Server
  doctest Subject

  setup [:start_client, :start_server]

  defp start_client(_context) do
    # generate unique handle for each test to avoid broadcast clashes
    handle = String.to_atom(inspect(make_ref()))
    {:ok, client} = Subject.start_link(ui: :echo, handle: handle, listener: self())
    [client: client, handle: handle]
  end

  defp start_server(context) do
    {:ok, server} = Server.start_link(client_handle: context.handle)
    Process.whereis(:server_socket)
    |> PantryServer.Socket.schedule_blink(loop: false, delay: 0)
    # wait for server to register
    refute_receive nil, 50

    {:ok, server: server}
  end

  @tag :interop
  test "registers new servers correctly", context do
    client_socket = Subject.child(context.client, Socket)
    server_socket = Process.whereis(:server_socket)
    state = PantryServer.State.pure(server_socket)
    assert ^state = PantryClient.Socket.get_state(client_socket)
    assert_receive {:echo, ^state}
  end

  @tag :interop
  test "adds torrents correctly", context do
    client_socket = Subject.child(context.client, Socket)
    server_socket = Process.whereis(:server_socket)
    msg = {:added_torrent, "0"}
    {:ok, state} = PantryServer.State.pure(server_socket) |> PantryServer.State.parse(msg)

    GenServer.cast(client_socket, {:info, server_socket, msg})
    assert_receive {:echo, ^state}
    assert ^state = PantryClient.Socket.get_state(client_socket)
  end

  @tag :interop
  test "server side event broadcasts work", context do
    server_socket = Process.whereis(:server_socket)
    PantryServer.Socket.request_torrent_add(:server_socket, %{file: "../../contrib/nmap.torrent"})
    refute_receive nil, 100

    socket = Subject.child(context.client, Socket)
    %{torrents: ts, servers: [^server_socket]} = PantryClient.Socket.get_state(socket)
    assert Enum.count(ts) == 1
  end
end
