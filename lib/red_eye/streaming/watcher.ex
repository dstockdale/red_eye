defmodule RedEye.Streaming.Watcher do
  def auto_subscribe do
    binance_symbols()
    |> RedEye.Streaming.Binance.subscribe(:rand.uniform(10))
  end

  defp binance_symbols do
    RedEye.MarketData.distinct_symbols()
    |> Enum.map(fn symbol -> "#{String.downcase(symbol)}@ticker" end)
  end
end
