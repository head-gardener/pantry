defmodule PantryServer.TorrentEngineTest do
  use ExUnit.Case, async: true
  alias PantryServer.TorrentEngine, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    assert {:ok, port} = Subject.start_link(self())
    assert_receive {:port_started}
    {:ok, port: port}
  end

  test "add torrent", context do
    params = "../../contrib/nmap.torrent"
    Subject.add(context.port, params)
    assert_receive {:added_torrent, _}
  end

  test "crashes on port crash", %{port: port} do
    Process.flag(:trap_exit, true)

    params = "INVALID"
    Subject.add(port, params)

    # catch error msg
    assert_receive {:port_critical, _}

    # ensure port crashes
    assert_receive {:port_exit, _}
    assert_receive {:EXIT, ^port, _}
  end
end
