defmodule Huesilon.MixProject do
  use Mix.Project

  def project do
    [
      app: :huesilon,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Huesilon, []},
      extra_applications: [:logger, :cowboy, :plug],
      applications: [:httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:huex, git: "https://github.com/arijitdasgupta/huex.git", tag: "master"},
      {:nerves_ssdp_client, "~> 0.1"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
