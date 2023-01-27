defmodule PantryServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :pantry_server,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      # compilers: [:elixir_make] ++ Mix.compilers(),
    ]
  end

  def application do
    [
      mod: {PantryServer.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4"}
    ]
  end
end
