defmodule RedEye.MarketApis.BinanceSpot do
  @moduledoc """
  For importing candle data from Binance Spot Market
  """
  @base_url "https://www.binance.com"

  @spec base_url :: Req.Request.t()
  def base_url do
    Req.new(base_url: @base_url)
  end

  def fetch(start_time: start_time, symbol: symbol, interval: interval) do
    params = [
      symbol: symbol,
      startTime: start_time,
      interval: interval,
      limit: 1000
    ]

    case Req.get(base_url(), url: "/api/v3/klines", params: params) do
      {:ok, response} ->
        case response.status do
          200 ->
            response.body

          408 ->
            []

          _ ->
            raise "Kaboom!"
        end

      {:error, response} ->
        raise IO.inspect(response)
    end
  end

  @spec map_entries(list, {String, String}) :: list
  def map_entries(list, {symbol, interval}) do
    list
    |> Enum.map(fn item ->
      %{
        symbol: symbol,
        interval: interval,
        timestamp: timestamp(item, 0),
        open: decimal(item, 1),
        high: decimal(item, 2),
        low: decimal(item, 3),
        close: decimal(item, 4),
        volume: decimal(item, 5),
        kline_open_time: timestamp(item, 0),
        kline_close_time: timestamp(item, 6),
        quote_asset_volume: decimal(item, 7),
        number_of_trades: Enum.at(item, 8),
        taker_buy_base_asset_volume: decimal(item, 9),
        taker_buy_quote_asset_volume: decimal(item, 10),
        inserted_at: DateTime.utc_now(:millisecond),
        updated_at: DateTime.utc_now(:millisecond)
      }
    end)
  end

  defp timestamp(item, i) do
    item
    |> Enum.at(i)
    |> DateTime.from_unix!(:millisecond)

    # |> DateTime.truncate(:millisecond)
  end

  defp decimal(item, i) do
    item
    |> Enum.at(i)
    |> Decimal.new()
  end
end
