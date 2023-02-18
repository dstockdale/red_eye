defmodule RedEye.MarketApis.BinanceSpotQueries do
  import Ecto.Query, warn: false
  alias RedEye.MarketData.BinanceSpotCandle

  @doc """
  Find candles that are already in the db by their unix_timestamps.

  You want to do this because we don't want to clobber APIs with unnecessary requests and get banned.

  """
  def existing_candles(unix_timestamps, symbol) do
    from(s in BinanceSpotCandle,
      select: s.unix_time,
      where: s.unix_time in ^unix_timestamps,
      where: s.symbol == ^symbol
    )
  end
end
