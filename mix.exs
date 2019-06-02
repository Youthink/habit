defmodule Habit.Mixfile do
  use Mix.Project

  def project do
    [
      app: :habit,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Habit.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :ueberauth,
        :ueberauth_github,
        :timex,
        :ecto_timestamps,
        :edeliver
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:poison, "~> 3.1"},
      {:jason, "~> 1.0"},
      {:httpoison, "~> 1.0"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_github, "~> 0.7"},
      {:ecto_timestamps, "~> 1.0.0", git: "https://github.com/Youthink/ecto_timestamps"},
      {:timex, "~> 3.1"},
      {:edeliver, ">= 1.6.0"},
      {:distillery, "~> 2.0", warn_missing: false},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:cors_plug, "~> 2.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
