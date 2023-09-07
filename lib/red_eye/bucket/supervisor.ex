defmodule RedEye.Bucket.Supervisor do
  use Supervisor
  alias RedEye.MarketData.Bucket

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {Bucket, name: :symbols},
      {Bucket, name: :chart_intervals}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
