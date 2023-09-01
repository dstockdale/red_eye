defmodule RedEye.MarketData.BinanceSpotCandle do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          close: Decimal.t(),
          high: Decimal.t(),
          inserted_at: DateTime.t(),
          interval: String.t(),
          kline_close_time: DateTime.t(),
          kline_open_time: DateTime.t(),
          low: Decimal.t(),
          number_of_trades: integer(),
          open: Decimal.t(),
          quote_asset_volume: Decimal.t(),
          symbol: String.t(),
          taker_buy_base_asset_volume: Decimal.t(),
          taker_buy_quote_asset_volume: Decimal.t(),
          timestamp: DateTime.t(),
          unix_time: integer(),
          updated_at: DateTime.t(),
          volume: Decimal.t(),
          kline_closed: boolean()
        }

  @timestamps_opts [type: :utc_datetime]
  @primary_key false
  @foreign_key_type :binary_id
  schema "binance_spot_candles" do
    field(:time, :utc_datetime, virtual: true)
    field(:timestamp, :utc_datetime, primary_key: true)
    field(:symbol, :string, primary_key: true)
    field(:interval, :string, primary_key: true)
    field(:unix_time, :integer)
    field(:close, :decimal)
    field(:high, :decimal)
    field(:kline_close_time, :utc_datetime)
    field(:kline_open_time, :utc_datetime)
    field(:low, :decimal)
    field(:number_of_trades, :integer)
    field(:open, :decimal)
    field(:quote_asset_volume, :decimal)
    field(:taker_buy_base_asset_volume, :decimal)
    field(:taker_buy_quote_asset_volume, :decimal)
    field(:volume, :decimal)
    field(:kline_closed, :boolean, default: false, virtual: true)

    timestamps()
  end

  @doc false
  def changeset(binance_spot_candle, attrs) do
    binance_spot_candle
    |> cast(attrs, [
      :time,
      :timestamp,
      :symbol,
      :interval,
      :unix_time,
      :high,
      :low,
      :open,
      :close,
      :volume,
      :kline_open_time,
      :kline_close_time,
      :quote_asset_volume,
      :number_of_trades,
      :taker_buy_base_asset_volume,
      :taker_buy_quote_asset_volume
    ])
    |> validate_required([
      :timestamp,
      :symbol,
      :interval,
      :unix_time,
      :high,
      :low,
      :open,
      :close,
      :volume,
      :kline_open_time,
      :kline_close_time,
      :quote_asset_volume,
      :number_of_trades,
      :taker_buy_base_asset_volume,
      :taker_buy_quote_asset_volume
    ])
  end
end
