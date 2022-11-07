defmodule LibTorrentTest do
  use ExUnit.Case
  doctest LibTorrent

  test "nif" do 
    assert LibTorrent.hello() == 'Hello world!'
  end
end
