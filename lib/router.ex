defmodule Router do
  @behaviour GenServer

  def start() do
    GenServer.start(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_info(val, state) do
    case val do
      {:added, data} -> {:noreply, handle_added(data, state)}
      x -> "unexpected responce #{inspect(x)}"
    end
  end

  defp handle_added(data, state) do
    IO.puts("added #{data}")
    state
  end
end
