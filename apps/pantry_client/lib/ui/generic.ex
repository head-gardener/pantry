defmodule PantryClient.UI.Generic do
  @moduledoc """
  Generic interface for all user interfaces.
  """

  def display(server, state) do
    send(server, {:display, state})
  end
end
