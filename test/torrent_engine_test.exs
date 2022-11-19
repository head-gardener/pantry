defmodule Pantry.TorrentEngineTest do
  use ExUnit.Case
  doctest Pantry.TorrentEngine
  alias Pantry.TorrentEngine, as: Subject

  setup_all do
    assert {:ok, port} = Subject.start()

    {:ok, port: port}
  end

  test "msg", context do
    Subject.add(context.port, "examples/lain.torrent")

    Subject.close(context.port)
  end
end
