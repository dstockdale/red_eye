defmodule RedEyeWeb.ChartLiveTest do
  use RedEyeWeb.ConnCase

  import Phoenix.LiveViewTest
  import RedEye.ChartsFixtures

  @create_attrs %{default_interval: "some default_interval", exchange: "some exchange", symbol: "some symbol"}
  @update_attrs %{default_interval: "some updated default_interval", exchange: "some updated exchange", symbol: "some updated symbol"}
  @invalid_attrs %{default_interval: nil, exchange: nil, symbol: nil}

  defp create_chart(_) do
    chart = chart_fixture()
    %{chart: chart}
  end

  describe "Index" do
    setup [:create_chart]

    test "lists all charts", %{conn: conn, chart: chart} do
      {:ok, _index_live, html} = live(conn, ~p"/charts")

      assert html =~ "Listing Charts"
      assert html =~ chart.default_interval
    end

    test "saves new chart", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/charts")

      assert index_live |> element("a", "New Chart") |> render_click() =~
               "New Chart"

      assert_patch(index_live, ~p"/charts/new")

      assert index_live
             |> form("#chart-form", chart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#chart-form", chart: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/charts")

      assert html =~ "Chart created successfully"
      assert html =~ "some default_interval"
    end

    test "updates chart in listing", %{conn: conn, chart: chart} do
      {:ok, index_live, _html} = live(conn, ~p"/charts")

      assert index_live |> element("#charts-#{chart.id} a", "Edit") |> render_click() =~
               "Edit Chart"

      assert_patch(index_live, ~p"/charts/#{chart}/edit")

      assert index_live
             |> form("#chart-form", chart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#chart-form", chart: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/charts")

      assert html =~ "Chart updated successfully"
      assert html =~ "some updated default_interval"
    end

    test "deletes chart in listing", %{conn: conn, chart: chart} do
      {:ok, index_live, _html} = live(conn, ~p"/charts")

      assert index_live |> element("#charts-#{chart.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chart-#{chart.id}")
    end
  end

  describe "Show" do
    setup [:create_chart]

    test "displays chart", %{conn: conn, chart: chart} do
      {:ok, _show_live, html} = live(conn, ~p"/charts/#{chart}")

      assert html =~ "Show Chart"
      assert html =~ chart.default_interval
    end

    test "updates chart within modal", %{conn: conn, chart: chart} do
      {:ok, show_live, _html} = live(conn, ~p"/charts/#{chart}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chart"

      assert_patch(show_live, ~p"/charts/#{chart}/show/edit")

      assert show_live
             |> form("#chart-form", chart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#chart-form", chart: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/charts/#{chart}")

      assert html =~ "Chart updated successfully"
      assert html =~ "some updated default_interval"
    end
  end
end
