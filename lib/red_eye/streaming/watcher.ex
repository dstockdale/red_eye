defmodule RedEye.Streaming.Watcher do
  def auto_subscribe do
    binance_symbols()
    |> RedEye.Streaming.Binance.subscribe(:rand.uniform(10))
  end

  def binance_symbols do
    RedEye.MarketData.distinct_symbols()
    |> Enum.map(fn symbol ->
      [
        "#{String.downcase(symbol)}@ticker",
        "#{String.downcase(symbol)}@kline_1m"
      ]
    end)
    |> List.flatten()
  end
end
