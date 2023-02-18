defmodule RedEye.Charts.ChartQueries do
  @moduledoc """
  The ChartQueries context.
  """

  import Ecto.Query, warn: false
  import Ecto.Query.Timescaledb
  # alias RedEye.Repo

  alias RedEye.MarketData.BinanceSpotCandle

  def binance_spot_time_bucket(symbol, period \\ "4 hour") do
    interval = parse_interval(period)

    from(s in BinanceSpotCandle,
      select: [
        time_bucket(^interval, "timestamp", "bucket"),
        s.symbol,
        as(fragment("FIRST(open, timestamp)"), open),
        as(max(s.high), high),
        as(min(s.low), low),
        as(fragment("LAST(close, timestamp)"), close)
      ],
      where: [symbol: ^symbol],
      group_by: [fragment("bucket"), s.symbol],
      order_by: [desc: fragment("bucket")]
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
