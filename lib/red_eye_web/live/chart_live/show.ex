defmodule RedEyeWeb.ChartLive.Show do
  use RedEyeWeb, :live_view

  alias RedEye.Charts

  @intervals ["15 minute", "30 minute", "1 hour", "4 hour", "1 day"]
  @def_pricing %{last_price: 0}
  @def_interval "4 hour"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Charts.subscribe()

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    chart = Charts.get_chart!(id)

    candles =
      RedEye.MarketData.list_binance_candles_for_chart(chart.binance_symbol.symbol, "4 hour")

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

  def handle_info({:chart_updated, _chart}, socket) do
    # todo ui to inform something updated
    {:noreply, socket}
  end

  @impl true
  def handle_event(%{"from" => from, "to" => to}, _params, socket) do
    IO.inspect(from)
    IO.inspect(to)
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Chart"
  defp page_title(:edit), do: "Edit Chart"
end
