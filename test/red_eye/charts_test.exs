defmodule RedEye.ChartsTest do
  use RedEye.DataCase

  alias RedEye.Charts

  describe "charts" do
    alias RedEye.Charts.Chart

    import RedEye.ChartsFixtures

    @invalid_attrs %{default_interval: nil, exchange: nil, symbol: nil}

    test "list_charts/0 returns all charts" do
      chart = chart_fixture()
      assert Charts.list_charts() == [chart]
    end

    test "get_chart!/1 returns the chart with given id" do
      chart = chart_fixture()
      assert Charts.get_chart!(chart.id) == chart
    end

    test "create_chart/1 with valid data creates a chart" do
      valid_attrs = %{default_interval: "some default_interval", exchange: "some exchange", symbol: "some symbol"}

      assert {:ok, %Chart{} = chart} = Charts.create_chart(valid_attrs)
      assert chart.default_interval == "some default_interval"
      assert chart.exchange == "some exchange"
      assert chart.symbol == "some symbol"
    end

    test "create_chart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Charts.create_chart(@invalid_attrs)
    end

    test "update_chart/2 with valid data updates the chart" do
      chart = chart_fixture()
      update_attrs = %{default_interval: "some updated default_interval", exchange: "some updated exchange", symbol: "some updated symbol"}

      assert {:ok, %Chart{} = chart} = Charts.update_chart(chart, update_attrs)
      assert chart.default_interval == "some updated default_interval"
      assert chart.exchange == "some updated exchange"
      assert chart.symbol == "some updated symbol"
    end

    test "update_chart/2 with invalid data returns error changeset" do
      chart = chart_fixture()
      assert {:error, %Ecto.Changeset{}} = Charts.update_chart(chart, @invalid_attrs)
      assert chart == Charts.get_chart!(chart.id)
    end

    test "delete_chart/1 deletes the chart" do
      chart = chart_fixture()
      assert {:ok, %Chart{}} = Charts.delete_chart(chart)
      assert_raise Ecto.NoResultsError, fn -> Charts.get_chart!(chart.id) end
    end

    test "change_chart/1 returns a chart changeset" do
      chart = chart_fixture()
      assert %Ecto.Changeset{} = Charts.change_chart(chart)
    end
  end
end
