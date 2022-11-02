defmodule PantryTest do
  use ExUnit.Case
  doctest Pantry

  test "greets the world" do
    assert Pantry.hello() == :world
  end
end
