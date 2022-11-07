defmodule PantryTest do
  use ExUnit.Case
  doctest Pantry

  test "greets the world" do
    assert Pantry.hello() == :world
  end

  test "factorial" do 
    assert Pantry.fact(1) == 1
    assert Pantry.fact(3) == 6
  end
end
