defmodule PantryClient.UI.Echo do
  @moduledoc """
  Echoing UI for testing.
  """

  def start_link(receiver) do
    Task.start_link(fn ->
      listen(receiver)
    end)
  end

  def listen(receiver) do
    :ok = receive do
      {:display, state} ->
        send(receiver, {:echo, state})
        :ok
      _ -> :ok
    end

    listen(receiver)
  end
end
