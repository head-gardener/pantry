defmodule Pantry.Server.StateTest do
  use ExUnit.Case, async: true
  alias Pantry.Server.State, as: Subject
  doctest Subject

  test "torrents" do
    pure = Subject.pure()

    {:ok, state} = Subject.parse(pure, {:added_torrent, 0})
    assert %{torrents: [0]} = state

    {:ok, ^pure} = Subject.parse(state, {:removed_torrent, 0})
  end
end
