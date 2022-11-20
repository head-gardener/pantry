defmodule Pantry do
  def start do
    {:ok, router} = Pantry.Router.start() 
    {:ok, engine} = Pantry.TorrentEngine.start() 

    true = Process.register(router, :router)
    true = Process.register(engine, :engine)

    :ok
  end
end
