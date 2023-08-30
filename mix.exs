defmodule RedEye.MixProject do
  use Mix.Project

  def project do
    [
      app: :red_eye,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      mod: {RedEye.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.19.3"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:req, "~> 0.3"},
      {:oban, "~> 2.13"},
      {:ecto_timescaledb, "~> 0.10.0"},
      {:cachex, "~> 3.6"},
      {:ex_machina, "~> 2.7.0", only: :test},
      {:websockex, "~> 0.4.3"},
      {:explorer, "~> 0.5.0"},
      {:number, "~> 1.0.3"},
      {:mint_web_socket, "~> 1.0"},
      {:live_select, "~> 1.1"},
      {:nimble_totp, "~> 1.0"},
      {:eqrcode, "~> 0.1.10"},
      {:twix, "~> 0.3.0"},
      {:timex, "~> 3.0"},
      {:petal_components, "~> 1.2"},
      {:phoenix_live_react, "~> 0.4"},
      {:nebulex, "~> 2.5"},
      {:decorator, "~> 1.4"},
      {:ecto_psql_extras, "~> 0.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "cmd --cd assets npm install"],
      "assets.deploy": [
        "tailwind default --minify",
        "cmd --cd assets node build.js --deploy",
        "phx.digest"
      ]
    ]
  end
end
