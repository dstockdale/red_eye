defmodule RedEye.Charts.ChartQueries do
  @moduledoc """
  The ChartQueries context.
  """

  import Ecto.Query, warn: false

  alias RedEye.Charts.Chart
  alias RedEye.MarketData.BinanceSpotCandle

  def most_recent_candle(symbol) do
    from(s in BinanceSpotCandle,
      where: [symbol: ^symbol],
      select: max(s.timestamp)
    )
  end

  def symbols_for_candles do
    from(s in BinanceSpotCandle,
      select: s.symbol,
      distinct: s.symbol
    )
  end

  def most_recent_candle_dt(symbol) do
    from(s in BinanceSpotCandle,
      where: [symbol: ^symbol],
      select: [max(s.timestamp)]
    )
  end

  def binance_spot_time_bucket(symbol, period \\ "4 hour") do
    interval = parse_interval(period)

    from(s in BinanceSpotCandle,
      where: [symbol: ^symbol],
      group_by: [fragment("time")],
      order_by: [asc: fragment("time")],
      select: %{
        time:
          fragment(
            "cast(extract(epoch from time_bucket(?, timestamp)) AS BIGINT) AS time",
            ^interval
          ),
        open: fragment("FIRST(open, timestamp)"),
        high: max(s.high),
        low: min(s.low),
        close: fragment("LAST(close, timestamp)"),
        volume: sum(s.volume)
      }
    )
  end

  def binance_spot_time_bucket(symbol, period, %{
        "start_time" => start_time,
        "end_time" => end_time
      }) do
    interval = parse_interval(period)

    from(s in BinanceSpotCandle,
      where: [symbol: ^symbol],
      where: fragment("timestamp BETWEEN ? AND ?", ^start_time, ^end_time),
      group_by: [fragment("time")],
      order_by: [asc: fragment("time")],
      select: %{
        time:
          fragment(
            "cast(extract(epoch from time_bucket(?, timestamp)) AS BIGINT) AS time",
            ^interval
          ),
        open: fragment("FIRST(open, timestamp)"),
        high: max(s.high),
        low: min(s.low),
        close: fragment("LAST(close, timestamp)"),
        volume: sum(s.volume)
      }
    )
  end

  def list_charts_with_counts do
    from(c in Chart,
      select: [c]
    )
  end

  @spec parse_interval(String.t()) :: Postgrex.Interval.t()
  @spec parse_interval(integer(), <<_::8>>) :: Postgrex.Interval.t()

  def parse_interval(string) do
    {period, unit} = Integer.parse(string)

    unit =
      unit
      |> String.trim()
      |> String.slice(0, 1)

    parse_interval(period, unit)
  end

  def parse_interval(period, "m") do
    mins = period * 60
    %Postgrex.Interval{secs: mins}
  end

  def parse_interval(period, "h") do
    hours = period * 60 * 60
    %Postgrex.Interval{secs: hours}
  end

  def parse_interval(period, "d") do
    %Postgrex.Interval{days: period}
  end

  def parse_interval(period, "w") do
    weeks = period * 7
    %Postgrex.Interval{days: weeks}
  end

  def parse_interval(period, "M") do
    %Postgrex.Interval{months: period}
  end
end
