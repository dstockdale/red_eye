defmodule RedEye.ChartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RedEye.Charts` context.
  """

  @doc """
  Generate a chart.
  """
  def chart_fixture(attrs \\ %{}) do
    {:ok, chart} =
      attrs
      |> Enum.into(%{
        default_interval: "some default_interval",
        exchange: "some exchange",
        symbol: "some symbol"
      })
      |> RedEye.Charts.create_chart()

    chart
  end
end
