defmodule RedEye.MarketData.BinanceSymbol do
  @moduledoc """
  BinanceSymbol schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]
  @foreign_key_type :binary_id
  schema "binance_symbols" do
    field(:symbol, :string)
    field(:status, :string)
    field(:allow_trailing_stop, :boolean, default: false)
    field(:base_asset, :string)
    field(:base_asset_precision, :integer)
    field(:base_commission_precision, :integer)
    field(:is_margin_trading_allowed, :boolean, default: false)
    field(:is_spot_trading_allowed, :boolean, default: false)
    field(:quote_asset, :string)
    field(:quote_asset_precision, :integer)
    field(:quote_commission_precision, :integer)
    field(:quote_order_qty_allowed, :boolean, default: false)
    field(:quote_precision, :integer)
    field(:order_types, {:array, :string})
    field(:permissions, {:array, :string})

    timestamps()
  end

  @doc false
  def changeset(symbol, attrs) do
    symbol
    |> cast(attrs, [
      :symbol,
      :status,
      :allow_trailing_stop,
      :base_asset,
      :base_asset_precision,
      :base_commission_precision,
      :is_margin_trading_allowed,
      :is_spot_trading_allowed,
      :quote_asset,
      :quote_asset_precision,
      :quote_commission_precision,
      :quote_order_qty_allowed,
      :quote_precision,
      :order_types,
      :permissions
    ])
    |> validate_required([
      :symbol,
      :status,
      :allow_trailing_stop,
      :base_asset,
      :base_asset_precision,
      :base_commission_precision,
      :is_margin_trading_allowed,
      :is_spot_trading_allowed,
      :quote_asset,
      :quote_asset_precision,
      :quote_commission_precision,
      :quote_order_qty_allowed,
      :quote_precision,
      :order_types,
      :permissions
    ])
    |> unique_constraint([:symbol])
  end
end
