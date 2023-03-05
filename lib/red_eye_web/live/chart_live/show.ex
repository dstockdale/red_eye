defmodule RedEyeWeb.ChartLive.Show do
  use RedEyeWeb, :live_view

  alias RedEye.Charts

  @def_pricing %{last_price: 0}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Charts.subscribe()

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    chart = Charts.get_chart!(id)

    candles =
      RedEye.MarketData.list_binance_candles_for_chart(chart.binance_symbol.symbol, "1 hour")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_symbol, chart.binance_symbol.symbol)
     |> assign(:live_price, Decimal.new(0))
     |> assign(:chart, chart)
     |> assign(:chart_data, candles)}
  end

  @impl true
  def handle_info({event, :ticker}, %{assigns: %{current_symbol: current_symbol}} = socket) do
    pricing = Map.get(event, current_symbol, @def_pricing)

    {:noreply,
     socket
     |> assign(:live_price, Decimal.new(pricing[:last_price]))}
  end

  defp page_title(:show), do: "Show Chart"
  defp page_title(:edit), do: "Edit Chart"
end
