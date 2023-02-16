defmodule RedEye.MarketApis do
  alias RedEye.MarketApis.BinanceSpot
  alias RedEye.MarketData

  def import_binance_spot_candles(start_time: start_time, symbol: symbol, interval: interval) do
    BinanceSpot.fetch(start_time: start_time, symbol: symbol, interval: interval)
    |> BinanceSpot.map_entries({symbol, interval})
    |> MarketData.create_binance_spot_candle()
  end
end
