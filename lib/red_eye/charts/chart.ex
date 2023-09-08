defmodule RedEye.Charts.Chart do
  @moduledoc """
  Chart schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "charts" do
    field(:exchange, :string)
    field(:earliest_timestamp, :utc_datetime)
    belongs_to(:binance_symbol, RedEye.MarketData.BinanceSymbol)

    embeds_one :ticker, Ticker do
      field(:last_price, :decimal, default: 0)
      field(:price_change, :decimal, default: 0)
      field(:price_change_percent, :decimal, default: 0)
      field(:updated_at, :utc_datetime)
    end

    timestamps()
  end

  @doc false
  def changeset(chart, attrs) do
    chart
    |> cast(attrs, [:exchange, :binance_symbol_id, :earliest_timestamp])
    |> validate_required([:exchange])
    |> validate_inclusion(:exchange, ~w(binance bitget))
  end
end
