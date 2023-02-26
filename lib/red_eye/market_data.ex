defmodule RedEye.MarketData do
  @moduledoc """
  The MarketData context.
  """

  import Ecto.Query, warn: false
  alias RedEye.Repo

  alias RedEye.MarketData.BinanceSpotCandle

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
      from b in BinanceSymbol,
        where: ilike(b.symbol, ^search),
        order_by: b.symbol

    Repo.all(query)
  end
end
