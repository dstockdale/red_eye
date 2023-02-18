defmodule RedEye.BinanceSpotCandleFactory do
  defmacro __using__(_opts) do
    quote do
      def binance_spot_candle_factory do
        %RedEye.MarketData.BinanceSpotCandle{
          title: "My awesome article!",
          body: "Still working on it!"
        }
      end
    end
  end
end
