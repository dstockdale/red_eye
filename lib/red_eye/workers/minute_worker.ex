defmodule RedEye.Workers.MinuteWorker do
  use Oban.Worker, queue: :data_import, unique: [period: 30], max_attempts: 1

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: :ok
  def perform(_args) do
    symbols = RedEye.MarketData.find_binance_candle_symbols()

    symbols
    |> Enum.map(fn symbol ->
      start_date =
        RedEye.MarketData.find_most_recent_binance_spot_candle(symbol)
        |> DateTime.add(-1, :day)
        |> DateTime.to_date()

      RedEye.MarketApis.import_binance_spot_candles_from_date(
        start_date,
        symbol,
        "1m"
      )
    end)

    :ok
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)
end
