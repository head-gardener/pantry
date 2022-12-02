defmodule Pantry.Server.State do
  @moduledoc """
  A set of tools for manipulating over a monadic server state structure
  """

  @type state :: %{torrents: torrent_list()}
  @type torrent_list :: [torrent()]
  @type torrent :: any

  @spec pure() :: state
  def pure() do
    %{torrents: []} 
  end

  @spec join(state, state) :: state
  def join(a, b) do
    %{torrents: a.torrents ++ b.torrents}
  end

  @spec parse(state, torrent()) :: {:ok | :err, state}
  def parse(state, {:added_torrent, id}) do
    {:ok, bind(state, add(id))}
  end

  def parse(state, {:removed_torrent, id}) do
    {:ok, bind(state, remove(id))}
  end

  def parse(state, _) do
    {:error, state}
  end

  @spec bind(state, (torrent_list() -> state)) :: state
  def bind(%{torrents: ts}, f) do
    f.(ts)
  end

  @spec add(torrent()) :: (torrent_list() -> state)
  def add(id) do
    fn ts -> %{torrents: [id | ts]} end
  end

  @spec remove(torrent()) :: (torrent_list() -> state)
  def remove(id) do
    fn ts -> %{torrents: List.delete(ts, id)} end
  end
end
