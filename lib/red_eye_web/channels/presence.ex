defmodule RedEyeWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  @chart_view "chart-view"

  use Phoenix.Presence,
    otp_app: :red_eye,
    pubsub_server: RedEye.PubSub

  def chart_subscribe do
    Phoenix.PubSub.subscribe(RedEye.PubSub, @chart_view)
  end
end
