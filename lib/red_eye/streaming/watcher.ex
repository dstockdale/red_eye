defmodule RedEye.Streaming.Watcher do
  @moduledoc """
  sub things to binance stream...
  """
  def auto_subscribe do
    binance_symbols()
    |> RedEye.Streaming.Binance.subscribe(:rand.uniform(10))
  end

  def binance_symbols do
    RedEye.MarketData.distinct_symbols()
    |> Enum.map(fn symbol ->
      [
        "#{String.downcase(symbol)}@ticker",
        "#{String.downcase(symbol)}@kline_1m",
        "#{String.downcase(symbol)}@kline_1h"
      ]
    end)
    |> List.flatten()
  end
end
