defmodule RedEye.MarketApis.BinanceSpotMap do
  def map_entries(list, {symbol, interval}) do
    list
    |> Enum.map(fn item -> map_entry(symbol, interval, item) end)
  end

  @spec map_entry(String.t(), String.t(), map()) :: %{
          close: Decimal.t(),
          high: Decimal.t(),
          inserted_at: DateTime.t(),
          interval: any,
          kline_close_time: DateTime.t(),
          kline_open_time: DateTime.t(),
          low: Decimal.t(),
          number_of_trades: any,
          open: Decimal.t(),
          quote_asset_volume: Decimal.t(),
          symbol: any,
          taker_buy_base_asset_volume: Decimal.t(),
          taker_buy_quote_asset_volume: Decimal.t(),
          timestamp: DateTime.t(),
          unix_time: any,
          updated_at: DateTime.t(),
          volume: Decimal.t()
        }
  def map_entry(symbol, interval, item) do
    %{
      symbol: symbol,
      interval: interval,
      timestamp: timestamp(item, 0),
      unix_time: Enum.at(item, 0),
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
      inserted_at: now(),
      updated_at: now()
    }
  end

  defp timestamp(item, i) do
    item
    |> Enum.at(i)
    |> to_integer()
    |> DateTime.from_unix!(:millisecond)
    |> DateTime.truncate(:second)
  end

  defp to_integer(string) when is_binary(string), do: String.to_integer(string)
  defp to_integer(number) when is_number(number), do: number

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end

  defp decimal(item, i) do
    item
    |> Enum.at(i)
    |> Decimal.new()
  end
end
