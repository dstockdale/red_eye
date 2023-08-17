defmodule RedEye.MarketData.BinanceSpotCandle do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime]
  @primary_key false
  @foreign_key_type :binary_id
  schema "binance_spot_candles" do
    field :time, :utc_datetime, virtual: true
    field :timestamp, :utc_datetime, primary_key: true
    field :symbol, :string, primary_key: true
    field :interval, :string, primary_key: true
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
