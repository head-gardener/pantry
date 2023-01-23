defmodule PantryClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :pantry_client,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {PantryClient.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:pantry_server, in_umbrella: true},
      {:ex_ncurses, "~> 0.3"}
    ]
  end
end
