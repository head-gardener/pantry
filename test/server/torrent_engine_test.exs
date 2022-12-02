defmodule Pantry.Server.TorrentEngineTest do
  use ExUnit.Case, async: true
  alias Pantry.Server.TorrentEngine, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    assert {:ok, port} = Subject.start_link(self())

    {:ok, port} =
      receive do
        {:port_started} -> {:ok, port}
        x -> x
      after
        1_000 -> :timeout
      end

    {:ok, port: port}
  end

  test "add torrent", context do
    params = "examples/nmap.torrent"
    Subject.add(context.port, params)

    :ok =
      receive do
        {:added_torrent, _} -> :ok
        x -> x
      after
        1_000 -> :timeout 
      end
  end

  test "crashes on port crash", %{port: port} do
    Process.flag(:trap_exit, true)

    params = "INVALID"
    Subject.add(port, params)

    # catch error msg
    :ok =
      receive do
        {:port_critical, _} -> :ok
      after
        1_000 -> :timeout
      end

    # ensure port crashes
    :ok =
      receive do
        {:port_exit, _} -> :ok
      after
        1_000 -> :timeout
      end

    :ok =
      receive do
        {:EXIT, ^port, _} -> :ok
      after
        1_000 -> :timeout
      end
  end
end
