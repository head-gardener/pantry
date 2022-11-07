defmodule Pantry do
  def hello do
    :world
  end

  def fact(1) do
    1
  end

  def fact(0) do
    0
  end

  def fact(x) do
    x * fact(x - 1)
  end
end
