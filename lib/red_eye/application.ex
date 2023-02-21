defmodule RedEye.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RedEyeWeb.Telemetry,
      # Start the Ecto repository
      RedEye.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: RedEye.PubSub},
      # Start Finch
      {Finch, name: RedEye.Finch},
      # Start the Endpoint (http/https)
      RedEyeWeb.Endpoint,
      # Start a worker by calling: RedEye.Worker.start_link(arg)
      # {RedEye.Worker, arg}
      {Oban, Application.fetch_env!(:red_eye, Oban)},
      RedEye.Charts.ChartListener
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RedEye.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RedEyeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
