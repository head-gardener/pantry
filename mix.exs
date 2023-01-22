defmodule Pantry.MixProject do
  use Mix.Project

  def project do
    [
      app: :pantry,
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    []
  end
end
