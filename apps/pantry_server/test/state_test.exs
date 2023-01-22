defmodule PantryServer.StateTest do
  use ExUnit.Case, async: true
  alias PantryServer.State, as: Subject
  doctest Subject

  test "torrents" do
    self = self()
    pure = Subject.pure(self)

    {:ok, state} = Subject.parse(pure, {:added_torrent, 0})
    assert %{torrents: [0], servers: [^self]} = state

    assert {:ok, ^pure} = Subject.parse(state, {:removed_torrent, 0})
  end

  test "servers" do
    pure = Subject.pure(self())

    assert ^pure = Subject.join(pure, pure)
  end

  test "knows" do
    state = Subject.pure(self())

    assert Subject.knows?(state, self())
    assert !Subject.knows?(state, :wrong)

    state = Subject.pure()

    assert !Subject.knows?(state, self())
  end
end
