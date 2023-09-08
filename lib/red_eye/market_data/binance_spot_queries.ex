defmodule RedEye.MarketData.BinanceSpotQueries do
  @moduledoc """
  Collection of queries for BinanceSpotCandle schema
  """
  import Ecto.Query, warn: false
  alias RedEye.MarketData.BinanceSpotCandle

  @doc """
  Find candles that are already in the db by their unix_timestamps.

  You want to do this because we don't want to clobber APIs with unnecessary requests and get banned.

  """
  @spec existing_candles(list, String) :: Ecto.Query.t()
  def existing_candles(unix_timestamps, symbol) do
    from(s in BinanceSpotCandle,
      select: s.unix_time,
      where: s.unix_time in ^unix_timestamps,
      where: s.symbol == ^symbol
    )
  end

  @doc """
  Find the oldest candle we have in the db
  """
  @spec oldest_candle(String) :: Ecto.Query.t()
  def oldest_candle(symbol) do
    from(s in BinanceSpotCandle,
      select: min(s.timestamp),
      where: s.symbol == ^symbol,
      limit: 1
    )
  end

  @spec lead_times_query(String) :: Ecto.Query.t()
  def lead_times_query(symbol) do
    from(s in BinanceSpotCandle,
      select: %{
        time: s.timestamp,
        lead_time: fragment("LEAD(timestamp) OVER (ORDER BY timestamp)"),
        diff: fragment("LEAD(timestamp) OVER (ORDER BY timestamp) - timestamp")
      },
      where: s.symbol == ^symbol
    )
  end

  @spec gaps_query(String) :: Ecto.Query.t()
  def gaps_query(symbol) do
    lead_times = lead_times_query(symbol)

    from(s in subquery(lead_times),
      select: %{
        from: fragment("time + INTERVAL '1 MINUTE'"),
        to: fragment("lead_time - INTERVAL '1 MINUTE'"),
        diff: fragment("diff - INTERVAL '2 MINUTE'")
      },
      where: fragment("diff > INTERVAL '1 MINUTE'"),
      order_by: {:desc, s.time}
    )
  end
end
