defmodule RedEye.Charts do
  @moduledoc """
  The Charts context.
  """

  import Ecto.Query, warn: false
  alias RedEye.Repo

  alias RedEye.Charts.Chart

  def symbol_options(string \\ "") when is_binary(string) do
    RedEye.MarketData.list_binance_symbols(string)
    |> Enum.map(fn item ->
      [key: item.symbol, value: item.id]
    end)
  end

  def exchange_options do
    [
      [key: "Binance", value: "binance"],
      [key: "Bitget", value: "bitget"]
    ]
  end

  @doc """
  Returns the list of charts.

  ## Examples

      iex> list_charts()
      [%Chart{}, ...]

  """
  def list_charts(preload \\ [:binance_symbol]) do
    Repo.all(Chart)
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single chart.

  Raises `Ecto.NoResultsError` if the Chart does not exist.

  ## Examples

      iex> get_chart!(123)
      %Chart{}

      iex> get_chart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chart!(id, preload \\ [:binance_symbol]) do
    Repo.get!(Chart, id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a chart.

  ## Examples

      iex> create_chart(%{field: value})
      {:ok, %Chart{}}

      iex> create_chart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chart(attrs \\ %{}) do
    %Chart{}
    |> Chart.changeset(attrs)
    |> Repo.insert()
    |> handle_changes()
    |> broadcast(:chart_created)
  end

  @doc """
  Updates a chart.

  ## Examples

      iex> update_chart(chart, %{field: new_value})
      {:ok, %Chart{}}

      iex> update_chart(chart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chart(%Chart{} = chart, attrs) do
    chart
    |> Chart.changeset(attrs)
    |> Repo.update()
    |> handle_changes()
    |> broadcast(:chart_updated)
  end

  @doc """
  Deletes a chart.

  ## Examples

      iex> delete_chart(chart)
      {:ok, %Chart{}}

      iex> delete_chart(chart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chart(%Chart{} = chart) do
    Repo.delete(chart)
  end

  defp handle_changes({:ok, chart}) do
    RedEye.Workers.ChartChangesWorker.new(%{
      chart_id: chart.id,
      earliest_timestamp: chart.earliest_timestamp
    })
    |> Oban.insert()

    {:ok, chart}
  end

  defp handle_changes({:error, _reason} = error), do: error

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chart changes.

  ## Examples

      iex> change_chart(chart)
      %Ecto.Changeset{data: %Chart{}}

  """
  def change_chart(%Chart{} = chart, attrs \\ %{}) do
    Chart.changeset(chart, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(RedEye.PubSub, "charts")
  end

  defp broadcast({:ok, chart}, event) do
    Phoenix.PubSub.broadcast(
      RedEye.PubSub,
      "charts",
      {event, chart}
    )

    {:ok, chart}
  end

  defp broadcast({:error, _reason} = error, _event), do: error
end
