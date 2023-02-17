import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :red_eye, RedEye.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "red_eye_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :red_eye, RedEyeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "WEXk4yGRJoXnjdQm4zjUepmpf+D84v7/ep3DoYa7FYPtsxU/jCjXNQYEYijXJdfg",
  server: false

# In test we don't send emails.
config :red_eye, RedEye.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :red_eye, Oban, testing: :inline
