defmodule PantryClient.UI.Console do
  require Logger
  @behaviour GenServer

  alias PantryServer.State

  @moduledoc """
  TUI for pantry client using ncurses.
  """

  def start_link(parent) do
    GenServer.start_link(__MODULE__, parent)
  end

  @impl true
  def init(parent) do
    Logger.debug("Console UI #{inspect(self())} initializing")

    ExNcurses.initscr()
    torrents_window = ExNcurses.newwin(20, 40, 1, 0)
    servers_window = ExNcurses.newwin(20, 40, 1, 41)
    windows = {torrents_window, servers_window}
    ExNcurses.listen()
    ExNcurses.noecho()
    ExNcurses.keypad()
    ExNcurses.curs_set(0)

    draw_state(State.pure(), windows)

    {:ok, {parent, windows, State.pure()}}
  end

  @impl true
  def terminate(reason, _) do
    Logger.debug("Console UI #{inspect(self())} terminating with reason #{inspect(reason)}")

    ExNcurses.stop_listening()
    ExNcurses.endwin()

    reason
  end

  def draw_state(state, {torrents_window, servers_window}) do
    torrents =
      State.map(state, fn {ts, _} ->
        ts
      end)

    servers =
      State.map(state, fn {_, ss} ->
        Enum.map(ss, &inspect(&1))
      end)

    ExNcurses.clear()
    ExNcurses.mvaddstr(0, 1, "torrents")
    ExNcurses.mvaddstr(0, 42, "servers")

    ExNcurses.wclear(servers_window)
    ExNcurses.wclear(torrents_window)

    ExNcurses.wmove(torrents_window, 1, 1)
    Enum.map(torrents, fn t ->
      ExNcurses.waddstr(torrents_window, t <> "\n ")
    end)
    ExNcurses.wborder(torrents_window)

    ExNcurses.wmove(servers_window, 1, 1)
    Enum.map(servers, fn t ->
      ExNcurses.waddstr(servers_window, t <> "\n ")
    end)
    ExNcurses.wborder(torrents_window)


    ExNcurses.wborder(servers_window)

    ExNcurses.refresh()
    ExNcurses.wrefresh(torrents_window)
    ExNcurses.wrefresh(servers_window)

    state
  end

  @impl true
  def handle_info({:display, state}, {parent, windows, _}) do
    draw_state(state, windows)
    {:noreply, {parent, windows, state}}
  end

  @impl true
  def handle_info({:ex_ncurses, :key, ?q}, {parent, windows, state}) do
    {:stop, :terminate, {parent, windows, state}}
  end

  @impl true
  def handle_info({:ex_ncurses, :key, ?t}, {parent, windows, state}) do
    state =
      state
      |> State.bind(State.add("123"))
      |> draw_state(windows)

    {:noreply, {parent, windows, state}}
  end

  @impl true
  def handle_info({:ex_ncurses, :key, key}, {parent, windows, state}) do
    Logger.warning("Unexpected key: #{inspect(key)}")
    {:noreply, {parent, windows, state}}
  end
end
