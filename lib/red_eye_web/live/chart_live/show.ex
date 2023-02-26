defmodule RedEyeWeb.ChartLive.Show do
  use RedEyeWeb, :live_view

  alias RedEye.Charts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    chart = Charts.get_chart!(id, [:binance_symbol])

    candles =
      RedEye.MarketData.list_binance_candles_for_chart(chart.binance_symbol.symbol, "1 hour")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:chart, chart)
     |> assign(:chart_data, candles)}
  end

  defp page_title(:show), do: "Show Chart"
  defp page_title(:edit), do: "Edit Chart"
end
