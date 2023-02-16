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
  Gets a single binance_spot_candle.

  Raises `Ecto.NoResultsError` if the Binance spot candle does not exist.

  ## Examples

      iex> get_binance_spot_candle!(123)
      %BinanceSpotCandle{}

      iex> get_binance_spot_candle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_binance_spot_candle!(id), do: Repo.get!(BinanceSpotCandle, id)

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
  Updates a binance_spot_candle.

  ## Examples

      iex> update_binance_spot_candle(binance_spot_candle, %{field: new_value})
      {:ok, %BinanceSpotCandle{}}

      iex> update_binance_spot_candle(binance_spot_candle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_binance_spot_candle(%BinanceSpotCandle{} = binance_spot_candle, attrs) do
    binance_spot_candle
    |> BinanceSpotCandle.changeset(attrs)
    |> Repo.update()
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
end
