defmodule RedEye.StreamSupervisor do
  use Supervisor

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {RedEye.MarketData.BinanceStream, name: :binance_stream}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
