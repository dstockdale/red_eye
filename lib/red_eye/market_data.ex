defmodule RedEye.MarketData do
  @moduledoc """
  The MarketData context.
  """

  import Ecto.Query, warn: false
  use Nebulex.Caching

  alias RedEye.Repo
  alias RedEye.Cache
  alias RedEye.MarketData.{BinanceSpotCandle, BinanceSpotQueries}

  @ttl :timer.hours(1)

  @doc """
  Returns the list of binance_spot_candles.

  ## Examples

      iex> list_binance_spot_candles()
      [%BinanceSpotCandle{}, ...]

  """
  def list_binance_spot_candles do
    Repo.all(BinanceSpotCandle)
  end

  @doc """
  Returns the list of high, low, open, close values.

  ## Examples

      iex> list_binance_candles_for_chart()
      [%{time: ~N[]}, ...]

  """
  def list_binance_candles_for_chart(symbol, period \\ "4 hours") do
    RedEye.Charts.ChartQueries.binance_spot_time_bucket(symbol, period)
    |> Repo.all()
  end

  def candle_chart(symbol, interval) do
    end_time = most_recent_candle(symbol)
    candle_chart(symbol, interval, %{from_end_time: end_time})
  end

  def candle_chart(symbol, interval, %{from_end_time: end_time}) do
    opts = start_and_end_from_end_time(end_time)
    candle_chart(symbol, interval, opts)
  end

  def candle_chart(
        symbol,
        interval,
        %{"start_time" => _start_time, "end_time" => _end_time} = opts
      ) do
    RedEye.Charts.ChartQueries.binance_spot_time_bucket(symbol, interval, opts)
    |> Repo.all()
  end

  def swing_chart(symbol, interval) do
    end_time = most_recent_candle(symbol)
    swing_chart(symbol, interval, %{from_end_time: end_time})
  end

  def swing_chart(symbol, interval, %{from_end_time: end_time}) do
    opts = start_and_end_from_end_time(end_time)
    swing_chart(symbol, interval, opts)
  end

  def swing_chart(
        symbol,
        interval,
        %{"start_time" => _start_time, "end_time" => _end_time} = opts
      ) do
    RedEye.Charts.SwingQueries.binance_spot_time_bucket(symbol, interval, opts)
    |> RedEye.Charts.SwingQueries.add_previous_high_low()
    |> RedEye.Charts.SwingQueries.add_candle_type()
    |> RedEye.Charts.SwingQueries.add_prev_candle_types()
    |> RedEye.Charts.SwingQueries.add_swing_grp()
    |> RedEye.Charts.SwingQueries.add_swing_dir()
    |> RedEye.Charts.SwingQueries.add_prev_next_swing_dir()
    |> RedEye.Charts.SwingQueries.add_pivots()
    |> Repo.all()
  end

  def most_recent_candle(symbol) do
    RedEye.Charts.ChartQueries.most_recent_candle_dt(symbol)
    |> Repo.one()
    |> List.first()
  end

  def start_and_end_from_end_time(end_time, diff \\ -10, period \\ :day) do
    start_time = DateTime.add(end_time, diff, period)

    %{"start_time" => start_time, "end_time" => end_time}
  end

  @doc """
  Creates a binance_spot_candle.

  ## Examples

      iex> create_binance_spot_candle(%{field: value})
      {:ok, %BinanceSpotCandle{}}

      iex> create_binance_spot_candle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_binance_spot_candle(attrs \\ %{})

  def create_binance_spot_candle(attrs) when is_map(attrs) do
    %BinanceSpotCandle{}
    |> BinanceSpotCandle.changeset(attrs)
    |> Repo.insert()
  end

  def create_binance_spot_candle(list) when is_list(list) do
    Repo.insert_all(BinanceSpotCandle, list, on_conflict: :nothing)
  end

  @doc """
  Deletes a binance_spot_candle.

  ## Examples

      iex> delete_binance_spot_candle(binance_spot_candle)
      {:ok, %BinanceSpotCandle{}}

      iex> delete_binance_spot_candle(binance_spot_candle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_binance_spot_candle(%BinanceSpotCandle{} = binance_spot_candle) do
    Repo.delete(binance_spot_candle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking binance_spot_candle changes.

  ## Examples

      iex> change_binance_spot_candle(binance_spot_candle)
      %Ecto.Changeset{data: %BinanceSpotCandle{}}

  """
  def change_binance_spot_candle(%BinanceSpotCandle{} = binance_spot_candle, attrs \\ %{}) do
    BinanceSpotCandle.changeset(binance_spot_candle, attrs)
  end

  def find_binance_candle_symbols do
    RedEye.Charts.ChartQueries.symbols_for_candles()
    |> Repo.all()
  end

  def find_most_recent_binance_spot_candle(symbol) do
    RedEye.Charts.ChartQueries.most_recent_candle(symbol)
    |> Repo.one()
  end

  alias RedEye.MarketData.BinanceSymbol

  def upsert_binance_symbols(symbols) do
    Repo.insert_all(BinanceSymbol, symbols,
      on_conflict: {:replace_all_except, [:symbol, :inserted_at]},
      conflict_target: [:symbol]
    )
  end

  def list_binance_symbols(search \\ "") do
    search = "%#{search}%"

    query =
      from(b in BinanceSymbol,
        where: ilike(b.symbol, ^search),
        order_by: b.symbol
      )

    Repo.all(query)
  end

  def search_binance_symbols(search \\ "") do
    search = "%#{search}%"

    query =
      from(b in BinanceSymbol,
        select: [b.symbol, b.id],
        where: ilike(b.symbol, ^search),
        order_by: b.symbol
      )

    Repo.all(query)
    |> list_to_tuples()
  end

  def list_to_tuples(list) when is_list(list) do
    list
    |> Enum.map(fn item ->
      List.to_tuple(item)
    end)
  end

  @decorate cacheable(cache: Cache, key: symbol, opts: [ttl: @ttl])
  def cached_gaps(symbol) do
    find_gaps(symbol)
  end

  def find_gaps(symbol) do
    BinanceSpotQueries.gaps_query(symbol)
    |> Repo.all()
  end

  def distinct_symbols do
    from(s in BinanceSpotCandle,
      select: [s.symbol],
      distinct: :symbol,
      order_by: :symbol
    )
    |> Repo.all()
    |> List.flatten()
  end
end
