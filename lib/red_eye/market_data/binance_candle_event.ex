defmodule RedEye.MarketData.BinanceCandleEvent do
  use Ecto.Schema

  @moduledoc """
  https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md#klinecandlestick-streams

  Stream Name: <symbol>@kline_<interval>

  Update Speed: 2000ms

  Payload:
  {
    "e": "kline",         // Event type
    "E": 1672515782136,   // Event time
    "s": "BNBBTC",        // Symbol
    "k": {
      "t": 1672515780000, // Kline start time
      "T": 1672515839999, // Kline close time
      "s": "BNBBTC",      // Symbol
      "i": "1m",          // Interval
      "f": 100,           // First trade ID
      "L": 200,           // Last trade ID
      "o": "0.0010",      // Open price
      "c": "0.0020",      // Close price
      "h": "0.0025",      // High price
      "l": "0.0015",      // Low price
      "v": "1000",        // Base asset volume
      "n": 100,           // Number of trades
      "x": false,         // Is this kline closed?
      "q": "1.0000",      // Quote asset volume
      "V": "500",         // Taker buy base asset volume
      "Q": "0.500",       // Taker buy quote asset volume
      "B": "123456"       // Ignore
    }
  }
  """

  embedded_schema do
    field :time, :utc_datetime
    field :symbol, :string
    field :interval, :string
    field :unix_time, :integer
    field :close, :decimal
    field :high, :decimal
    field :kline_close_time, :utc_datetime
    field :kline_open_time, :utc_datetime
    field :low, :decimal
    field :number_of_trades, :integer
    field :open, :decimal
    field :quote_asset_volume, :decimal
    field :taker_buy_base_asset_volume, :decimal
    field :taker_buy_quote_asset_volume, :decimal
    field :volume, :decimal
    field :is_kline_closed, :boolean, default: false
  end
end
