defmodule RedEye.Charts.Chart do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "charts" do
    field :exchange, :string
    field :earliest_timestamp, :utc_datetime
    belongs_to :binance_symbol, RedEye.MarketData.BinanceSymbol

    timestamps()
  end

  @doc false
  def changeset(chart, attrs) do
    chart
    |> cast(attrs, [:exchange, :binance_symbol_id])
    |> validate_required([:exchange])
    |> validate_inclusion(:exchange, ~w(binance bitget))
  end
end
