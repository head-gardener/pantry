defmodule PantryServer.ManagerTest do
  use ExUnit.Case
  alias PantryServer.Manager, as: Subject
  doctest Subject

  setup [:start]

  defp start(_context) do
    {:ok, manager} = Subject.start_link(self())

    [manager: manager]
  end
end
