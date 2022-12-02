defmodule Pantry.Client.StateAgent do
  alias Pantry.Server.State, as: State

  @moduledoc """
  Wraps around the state monad for state isolation 
  """

  @spec start_link() :: {:error, any} | {:ok, pid()}
  def start_link() do
    Agent.start_link(&State.pure/0)
  end

  @spec join(Agent.agent(), State.state()) :: :ok 
  def join(agent, state) do
    Agent.update(agent, &State.join(&1, state))
  end

  @spec parse(Agent.agent(), any) :: :ok 
  def parse(agent, msg) do
    Agent.update(agent, fn state ->
      {_, state} = State.parse(state, msg)
      state
    end)
  end

  @spec get(Agent.agent()) :: State.state()
  def get(agent) do
    Agent.get(agent, fn a -> a end)
  end
end
