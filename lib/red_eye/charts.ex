defmodule RedEye.Charts do
  @moduledoc """
  The Charts context.
  """

  import Ecto.Query, warn: false
  alias RedEye.Repo

  alias RedEye.Charts.Chart

  def interval_options do
    [
      "15 mins": "15 mins",
      "30 mins": "30 mins",
      "1 hour": "1 hour",
      "2 hours": "2 hours",
      "4 hours": "4 hours",
      "1 day": "1 day"
    ]
  end

  @doc """
  Returns the list of charts.

  ## Examples

      iex> list_charts()
      [%Chart{}, ...]

  """
  def list_charts do
    Repo.all(Chart)
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
  def get_chart!(id), do: Repo.get!(Chart, id)

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
