defmodule RedEye.Charts.SwingQueries do
  import Ecto.Query, warn: false
  alias RedEye.MarketData.BinanceSpotCandle

  @candle_types """
  CASE WHEN high > previous_high 	AND low > previous_low THEN 'up'
    WHEN high < previous_high AND low < previous_low THEN 'down'
    WHEN high <= previous_high AND low >= previous_low THEN 'outside'
    WHEN high >= previous_high AND low <= previous_low THEN NULL
  END
  """

  @pivots """
  CASE WHEN swing_dir IS NULL AND next_swing_dir = 'down' THEN high
    WHEN swing_dir IS NULL AND next_swing_dir = 'up' THEN low
    WHEN swing_dir = 'up' AND next_swing_dir = 'down' THEN high
    WHEN swing_dir = 'down' AND next_swing_dir = 'up' THEN low
    WHEN swing_dir = 'outside' AND candle_type IS NULL THEN NULL
    WHEN swing_dir = 'outside' AND prev_swing_dir = 'down' AND next_swing_dir = 'up' THEN low
    WHEN swing_dir = 'outside' AND prev_swing_dir = 'up' AND next_swing_dir = 'down' THEN high
    WHEN swing_dir = 'outside' AND prev_swing_dir = 'outside' AND next_swing_dir = 'down' THEN high
  END
  """

  def binance_spot_time_bucket(symbol, period, %{
        "start_time" => start_time,
        "end_time" => end_time
      }) do
    interval = RedEye.Charts.ChartQueries.parse_interval(period)

    from(s in BinanceSpotCandle,
      where: [symbol: ^symbol],
      where: fragment("timestamp BETWEEN ? AND ?", ^start_time, ^end_time),
      group_by: [fragment("time")],
      order_by: [asc: fragment("time")],
      select: %{
        time:
          fragment(
            "cast(extract(epoch from time_bucket(?, timestamp)) AS BIGINT)",
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

  def add_pivots(query) do
    from(s in subquery(query),
      select: %{
        time: s.time,
        high: s.high,
        low: s.low,
        previous_high: s.previous_high,
        previous_low: s.previous_low,
        candle_type: s.candle_type,
        prev_candle_type: s.prev_candle_type,
        next_candle_type: s.next_candle_type,
        swing_dir: s.swing_dir,
        pivot: fragment(@pivots)
      }
    )
  end

  def add_prev_next_swing_dir(query) do
    from(s in subquery(query),
      select: %{
        time: s.time,
        high: s.high,
        low: s.low,
        previous_high: s.previous_high,
        previous_low: s.previous_low,
        candle_type: s.candle_type,
        prev_candle_type: s.prev_candle_type,
        next_candle_type: s.next_candle_type,
        swing_dir: s.swing_dir,
        prev_swing_dir: fragment("LAG(swing_dir) OVER (ORDER BY time)"),
        next_swing_dir: fragment("LEAD(swing_dir) OVER (ORDER BY time)")
      }
    )
  end

  def add_swing_dir(query) do
    from(s in subquery(query),
      select: %{
        time: s.time,
        high: s.high,
        low: s.low,
        previous_high: s.previous_high,
        previous_low: s.previous_low,
        candle_type: s.candle_type,
        prev_candle_type: s.prev_candle_type,
        next_candle_type: s.next_candle_type,
        swing_dir: fragment("max(candle_type) over(partition by swing_grp order by time)")
      }
    )
  end

  def add_swing_grp(query) do
    from(s in subquery(query),
      select: %{
        time: s.time,
        high: s.high,
        low: s.low,
        previous_high: s.previous_high,
        previous_low: s.previous_low,
        candle_type: s.candle_type,
        prev_candle_type: s.prev_candle_type,
        next_candle_type: s.next_candle_type,
        swing_grp:
          fragment("sum(case when candle_type IS NULL then 0 else 1 end) over(order by time)")
      }
    )
  end

  def add_prev_candle_types(query) do
    from(s in subquery(query),
      select: %{
        time: s.time,
        high: s.high,
        low: s.low,
        previous_high: s.previous_high,
        previous_low: s.previous_low,
        candle_type: s.candle_type,
        prev_candle_type: fragment("LAG(candle_type) OVER (ORDER BY time)"),
        next_candle_type: fragment("LEAD(candle_type) OVER (ORDER BY time)")
      }
    )
  end

  def add_candle_type(query) do
    from(s in subquery(query),
      select: %{
        time: s.time,
        high: s.high,
        low: s.low,
        previous_high: s.previous_high,
        previous_low: s.previous_low,
        candle_type: fragment(@candle_types)
      }
    )
  end

  def add_previous_high_low(query) do
    from(s in subquery(query),
      select: %{
        time: s.time,
        high: s.high,
        low: s.low,
        previous_high: fragment("LAG(high) OVER (ORDER BY time)"),
        previous_low: fragment("LAG(low) OVER (ORDER BY time)")
      }
    )
  end
end
