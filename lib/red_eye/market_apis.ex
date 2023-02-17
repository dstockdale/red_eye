defmodule RedEye.MarketApis do
  alias RedEye.MarketApis.{BinanceSpot, Timing}
  alias RedEye.MarketData

  def import_binance_spot_candles_from_date(
        start_date,
        symbol,
        interval
      ) do
    timestamps = Timing.date_range(start_date)

    import_binance_spot_candles_jobs(symbol, interval, timestamps)
  end

  def import_binance_spot_candles(start_time, symbol, interval) do
    BinanceSpot.fetch(start_time, symbol, interval)
    |> BinanceSpot.map_entries({symbol, interval})
    |> MarketData.create_binance_spot_candle()
  end

  def import_binance_spot_candles_jobs(symbol, interval, timestamps) do
    changesets =
      timestamps
      |> Enum.map(fn start_time ->
        %{symbol: symbol, interval: interval, start_time: start_time}
        |> RedEye.Workers.ImportBinanceSpotCandlesWorker.new()
      end)

    Ecto.Multi.new()
    |> Oban.insert_all(:jobs, changesets)
    |> RedEye.Repo.transaction()
  end
end
