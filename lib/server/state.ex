defmodule Pantry.Server.State do
  @moduledoc """
  A set of tools for manipulating over a monadic server state structure
  """

  @type state :: %{torrents: torrent_list(), servers: server_list()}
  @type torrent_list :: [torrent()]
  @type server_list :: [server()]
  @type torrent :: any
  @type server :: any

  @type unwrapped :: {torrent_list(), server_list()}

  @type bindable :: (unwrapped -> state())
  @type mappable :: (unwrapped -> any)

  @spec pure() :: state()
  def pure() do
    %{torrents: [], servers: []}
  end

  @spec pure(server()) :: state()
  def pure(server) do
    %{torrents: [], servers: [server]}
  end

  @spec join(state(), state()) :: state()
  def join(a, b) do
    %{torrents: a.torrents ++ b.torrents, servers: Enum.dedup(a.servers ++ b.servers)}
  end

  @spec bind(state(), bindable()) :: state()
  def bind(%{torrents: ts, servers: ss}, f) do
    f.({ts, ss})
  end

  @spec map(state(), mappable()) :: any
  def map(%{torrents: ts, servers: ss}, f) do
    f.({ts, ss}) 
  end

  @doc """
  Parses a message tuple and attempts to modify state.
  """
  @spec parse(state(), {:added_torrent | :removed_torrent, any}) :: {:ok | :err, state}
  def parse(state, {:added_torrent, id}) do
    {:ok, bind(state, add(id))}
  end

  def parse(state, {:removed_torrent, id}) do
    {:ok, bind(state, remove(id))}
  end

  def parse(state, _) do
    {:error, state}
  end

  @spec add(torrent()) :: bindable()
  def add(id) do
    fn ({ts, ss}) -> %{torrents: [id | ts], servers: ss} end
  end

  @spec remove(torrent()) :: bindable()
  def remove(id) do
    fn ({ts, ss}) -> %{torrents: List.delete(ts, id), servers: ss} end
  end

  @spec knows?(state(), server()) :: boolean()
  def knows?(state, server) do
    f = fn ({_, ss}) -> Enum.member?(ss, server) end
    map(state, f)
  end
end
