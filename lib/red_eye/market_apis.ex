defmodule RedEye.MarketApis do
  alias RedEye.MarketApis.{BinanceSpot, BinanceSymbolReq, Timing}
  alias RedEye.MarketData
  alias RedEye.MarketData.BinanceSpotQueries
  alias RedEye.Repo

  def find_earliest_record(symbol) do
    nineteen_ninety_nine()
    |> BinanceSpot.fetch(symbol, "1h")
    |> Enum.sort_by(fn s -> Enum.at(s, 0) end)
    |> List.first()
    |> Enum.at(0)
    |> DateTime.from_unix!(:millisecond)
  end

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
      exclude_inserted_timestamps(timestamps, symbol)
      |> Enum.map(fn start_time ->
        %{symbol: symbol, interval: interval, start_time: start_time}
        |> RedEye.Workers.ImportBinanceSpotCandlesWorker.new()
      end)

    Ecto.Multi.new()
    |> Oban.insert_all(:jobs, changesets)
    |> RedEye.Repo.transaction()
  end

  def import_binance_symbols do
    BinanceSymbolReq.fetch()
    |> BinanceSymbolReq.map()
    |> MarketData.upsert_binance_symbols()
  end

  def fill_gaps(symbol) do
    gaps = MarketData.find_gaps(symbol)

    timestamps =
      gaps
      |> Enum.map(fn item ->
        item.from
        |> DateTime.from_naive!("Etc/UTC")
        |> DateTime.to_unix(:millisecond)
      end)

    import_binance_spot_candles_jobs(symbol, "1m", timestamps)
  end

  defp exclude_inserted_timestamps(timestamps, symbol) do
    already_inserted =
      BinanceSpotQueries.existing_candles(timestamps, symbol)
      |> Repo.all()

    timestamps -- already_inserted
  end

  # Before crypto began...
  defp nineteen_ninety_nine do
    DateTime.new!(~D[1999-12-31], ~T[00:00:00.000], "Etc/UTC")
    |> DateTime.to_unix(:millisecond)
  end
end
