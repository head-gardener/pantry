defmodule PantryClient.UI.Echo do
  require Logger

  @moduledoc """
  Echoing UI for testing.
  """

  def start_link(receiver) do
    Task.start_link(fn ->
      init(receiver)
    end)
  end

  def init(receiver) do
    Logger.debug("Echo UI #{inspect(self())} initializing")
    Process.register(self(), :ui)

    listen(receiver)
  end

  def listen(receiver) do
    :ok =
      receive do
        {:display, state} ->
          send(receiver, {:echo, state})
          :ok

        _ ->
          :ok
      end

    listen(receiver)
  end
end
