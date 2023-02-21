defmodule RedEye.ChartsTest do
  use RedEye.DataCase, async: true

  alias RedEye.Charts

  describe "charts" do
    alias RedEye.Charts.Chart

    import RedEye.ChartsFixtures

    setup do
      binance_symbol = insert(:binance_symbol)
      chart = insert(:chart, binance_symbol: binance_symbol)

      {:ok, chart: chart, binance_symbol: binance_symbol}
    end

    test "list_charts/0 returns all charts", %{chart: chart} do
      assert Charts.list_charts() == [chart]
    end

    test "get_chart!/1 returns the chart with given id", %{chart: chart} do
      assert Charts.get_chart!(chart.id) == chart
    end

    test "create_chart/1 with valid data creates a chart", %{binance_symbol: binance_symbol} do
      valid_attrs = %{
        exchange: "bitget",
        binance_symbol_id: binance_symbol.id
      }

      assert {:ok, %Chart{} = chart} = Charts.create_chart(valid_attrs)
      assert chart.exchange == "bitget"
    end

    test "create_chart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Charts.create_chart(%{exchange: nil})
    end

    test "update_chart/2 with valid data updates the chart", %{chart: chart} do
      update_attrs = %{
        exchange: "bitget"
      }

      assert {:ok, %Chart{} = chart} = Charts.update_chart(chart, update_attrs)
      assert chart.exchange == "bitget"
    end

    test "update_chart/2 with invalid data returns error changeset", %{chart: chart} do
      assert {:error, %Ecto.Changeset{}} = Charts.update_chart(chart, %{exchange: nil})
      assert chart == Charts.get_chart!(chart.id)
    end

    test "delete_chart/1 deletes the chart", %{chart: chart} do
      assert {:ok, %Chart{}} = Charts.delete_chart(chart)
      assert_raise Ecto.NoResultsError, fn -> Charts.get_chart!(chart.id) end
    end

    test "change_chart/1 returns a chart changeset", %{chart: chart} do
      assert %Ecto.Changeset{} = Charts.change_chart(chart)
    end
  end
end
