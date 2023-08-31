defmodule RedEye.Workers.MinuteWorker do
  use Oban.Worker, queue: :data_import, unique: [period: 30], max_attempts: 1

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: :ok
  def perform(_args) do
    RedEye.MarketData.find_binance_candle_symbols()
    |> Enum.map(fn symbol ->
      unixtime =
        RedEye.MarketData.most_recent_candle(symbol)
        |> DateTime.to_unix(:millisecond)

      RedEye.MarketApis.import_binance_spot_candles(unixtime, symbol, "1m")
    end)

    :ok
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)
end
