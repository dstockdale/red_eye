defmodule RedEye.MarketData.Ticker do
  @derive {Jason.Encoder,
           only: [:symbol, :price_change, :price_change_percent, :last_price, :updated_at]}
  defstruct [
    :symbol,
    price_change: Decimal.new(0),
    price_change_percent: Decimal.new(0),
    last_price: Decimal.new(0),
    updated_at: DateTime.utc_now()
  ]

  @type t :: %__MODULE__{
          symbol: String.t(),
          price_change: Decimal.t(),
          price_change_percent: Decimal.t(),
          last_price: Decimal.t(),
          updated_at: DateTime.t()
        }

  @spec new(keyword) :: t()
  def new(opts \\ []) do
    symbol = Keyword.get(opts, :symbol)
    last_price = Keyword.get(opts, :last_price)
    price_change = Keyword.get(opts, :price_change)
    price_change_percent = Keyword.get(opts, :price_change_percent)

    struct!(__MODULE__,
      symbol: symbol,
      price_change: Decimal.to_float(Decimal.new(price_change)),
      price_change_percent: Decimal.new(price_change_percent),
      last_price: Decimal.new(last_price),
      updated_at: DateTime.utc_now()
    )
  end
end
