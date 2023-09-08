defmodule RedEye.BinanceSpotCandleFactory do
  @moduledoc """
  Factory for BinanceSpotCandle
  """
  defmacro __using__(_opts) do
    quote do
      def binance_spot_candle_factory do
        now = DateTime.utc_now()

        %RedEye.MarketData.BinanceSpotCandle{
          timestamp: now,
          symbol: "BTCUSDT",
          interval: "1m",
          unix_time: now |> DateTime.to_unix(:millisecond),
          close: "2000000.00",
          high: "3000000.99",
          kline_close_time: now,
          kline_open_time: now,
          low: "1000000.99",
          number_of_trades: 100,
          open: "200001.66",
          quote_asset_volume: "34566.9876",
          taker_buy_base_asset_volume: "34566.9876",
          taker_buy_quote_asset_volume: "34566.9876",
          volume: "34566.9876"
        }
      end
    end
  end
end
