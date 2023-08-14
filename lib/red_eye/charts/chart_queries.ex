defmodule RedEye.Charts.ChartQueries do
  @moduledoc """
  The ChartQueries context.
  """

  import Ecto.Query, warn: false
  import Ecto.Query.Timescaledb

  # alias RedEye.Repo

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

  def list_charts_with_counts do
    from(c in Chart,
      select: [c]
    )
  end

  defp parse_interval(string) do
    [period, unit] = String.split(string, " ")

    parse_interval(String.to_integer(period), String.slice(unit, 0, 1))
  end

  defp parse_interval(period, "m") do
    mins = period * 60
    %Postgrex.Interval{secs: mins}
  end

  defp parse_interval(period, "h") do
    hours = period * 60 * 60
    %Postgrex.Interval{secs: hours}
  end

  defp parse_interval(period, "d") do
    days = period * 60 * 60 * 24
    %Postgrex.Interval{secs: days}
  end
end
