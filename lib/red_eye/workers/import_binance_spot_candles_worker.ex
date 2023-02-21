defmodule RedEye.Workers.ImportBinanceSpotCandlesWorker do
  use Oban.Worker, queue: :data_import

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: :ok
  def perform(%Oban.Job{
        args: %{
          "symbol" => symbol,
          "interval" => interval,
          "start_time" => start_time
        }
      }) do
    RedEye.MarketApis.import_binance_spot_candles(start_time, symbol, interval)

    :ok
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)
end
