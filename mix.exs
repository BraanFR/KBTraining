defmodule Project.MixProject do
  use Mix.Project

  def project do
    [
      app: :project,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      compilers: [:reaxt_webpack] ++ Mix.compilers,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      mod: {Project.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 2.1.0"},
      {:plug, "~> 1.10.0"},
      {:plug_cowboy, "~> 1.0.0"},
      {:reaxt, tag: "v2.1.0", github: "kbrw/reaxt"},
      {:exfsm, git: "https://github.com/kbrw/exfsm.git"},
      {:ewebmachine, "~> 2.2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
