defmodule RedEyeWeb.ChartLiveTest do
  use RedEyeWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs %{
    exchange: "binance"
  }
  @update_attrs %{
    exchange: "bitget"
  }

  defp create_chart(_) do
    binance_symbol = insert(:binance_symbol)
    chart = insert(:chart, binance_symbol: binance_symbol)
    %{chart: chart, binance_symbol: binance_symbol}
  end

  describe "Index" do
    setup [:create_chart]

    test "lists all charts", %{conn: conn, chart: chart} do
      {:ok, _index_live, html} = live(conn, ~p"/charts")

      assert html =~ "Listing Charts"
      assert html =~ chart.exchange
    end

    test "saves new chart", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/charts")

      assert index_live |> element("a", "New Chart") |> render_click() =~
               "New Chart"

      assert_patch(index_live, ~p"/charts/new")

      assert index_live
             |> form("#chart-form", chart: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/charts")

      html = render(index_live)
      assert html =~ "Chart created successfully"
    end

    test "deletes chart in listing", %{conn: conn, chart: chart} do
      {:ok, index_live, _html} = live(conn, ~p"/charts")

      assert index_live |> element("#charts-#{chart.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#charts-#{chart.id}")
    end
  end

  describe "Show" do
    setup [:create_chart]

    test "displays chart", %{conn: conn, chart: chart} do
      {:ok, _show_live, html} = live(conn, ~p"/charts/#{chart}")

      assert html =~ "Show Chart"
    end

    test "updates chart within modal", %{conn: conn, chart: chart} do
      {:ok, show_live, _html} = live(conn, ~p"/charts/#{chart}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chart"

      assert_patch(show_live, ~p"/charts/#{chart}/show/edit")

      assert show_live
             |> form("#chart-form", chart: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/charts/#{chart}")

      html = render(show_live)
      assert html =~ "Chart updated successfully"
    end
  end
end
