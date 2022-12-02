defmodule Pantry.Server.ManagerTest do
  use ExUnit.Case
  alias Pantry.Server.Manager, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    {:ok, manager} = Subject.start_link(self())

    [manager: manager]
  end
end
