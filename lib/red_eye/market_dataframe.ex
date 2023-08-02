defmodule RedEye.MarketDataframe do
  alias Explorer.DataFrame
  alias Explorer.Series
  require DataFrame, as: DF
  import Decimal, only: [is_decimal: 1]

  def map_list(list) do
    list
    |> Enum.map(fn item ->
      %{
        close: to_float(item.close),
        high: to_float(item.high),
        low: to_float(item.low),
        open: to_float(item.open),
        time: item.time,
        volume: to_float(item.volume)
      }
    end)
  end

  def to_float(item) when is_decimal(item) do
    Decimal.to_float(item)
  end

  def to_float(item) when is_float(item), do: item

  def dataframe(list) when is_list(list) do
    DataFrame.new(list)
  end

  def highs_and_lows(df) do
    previous_highs = Series.shift(df[:high], 1)
    previous_lows = Series.shift(df[:low], 1)
    higher_highs = Series.greater(df[:high], previous_highs)
    lower_lows = Series.less(df[:low], previous_lows)
    has_swings = Series.or(higher_highs, lower_lows)

    df
    |> DF.put(:higher_highs, higher_highs)
    |> DF.put(:lower_lows, lower_lows)
    |> DF.put(:has_swings, has_swings)
    |> DF.mask(has_swings)
    |> DF.mutate_with(fn item ->
      value =
        cond do
          item["higher_highs"] ->
            item["high"]

          item["lower_lows"] ->
            item["low"]
        end

      [value: value]
    end)
    |> DF.mutate(previous_value: Series.shift(value, 1))
    |> DF.mutate(trend: Series.greater(value, previous_value))
    |> DF.mutate(previous_trend: Series.shift(trend, 1))
    |> DF.mutate(trend_change: Series.not_equal(trend, previous_trend))
    |> DF.discard([
      "higher_highs",
      "lower_lows",
      "has_swings",
      "volume",
      "close",
      "high",
      "low",
      "open",
      "previous_trend",
      "trend",
      "previous_value"
    ])
    |> DF.group_by("time")
    |> DF.to_rows()
    |> Enum.group_by(fn item -> item["time"] end)
    |> Enum.sort()
  end

  # csv_file = Path.expand("btc-4hr-candles.csv", __DIR__)
  # df = DataFrame.from_csv!(csv_file)
  # previous_highs = Series.shift(df[:high], 1)
  # previous_lows = Series.shift(df[:low], 1)
  # previous_closes = Series.shift(df[:close], 1)
  # higher_highs = Series.greater(df[:high], previous_highs)
  # lower_lows = Series.less(df[:low], previous_lows)
  # has_swings = Series.or(higher_highs, lower_lows)

  # df =
  #   df
  #   |> DF.put(:higher_highs, higher_highs)
  #   |> DF.put(:lower_lows, lower_lows)
  #   |> DF.put(:has_swings, has_swings)
  #   |> DF.mask(has_swings)
  #   |> DF.mutate_with(fn item ->
  #     value =
  #       cond do
  #         item["higher_highs"] ->
  #           item["high"]

  #         item["lower_lows"] ->
  #           item["low"]
  #       end

  #     [value: value]
  #   end)
  #   |> DF.discard([
  #     "higher_highs",
  #     "lower_lows",
  #     "has_swings",
  #     "volume",
  #     "close",
  #     "high",
  #     "low",
  #     "open"
  #   ])
  #   |> DF.group_by("time")
  #   |> DF.to_rows()
  #   |> Enum.group_by(fn item -> item["time"] end)
end
