defmodule LibTorrent do 
  @on_load :load_nifs

  def load_nifs() do 
    :erlang.load_nif('native/libtorrent_nif/lib/libtorrent_nif', 0)
  end

  def hello() do 
    raise "not implemented"
  end
end
