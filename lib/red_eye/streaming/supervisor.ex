defmodule RedEye.Streaming.Supervisor do
  @moduledoc """
  Supervisor for the Biance websocket connection.

  Brings the connection back up when it goes down which happens often enough
  """
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      RedEye.Streaming.Binance
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
