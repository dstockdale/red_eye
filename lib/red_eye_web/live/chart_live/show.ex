defmodule RedEyeWeb.ChartLive.Show do
  alias RedEye.MarketData.Ticker
  use RedEyeWeb, :live_view

  alias RedEye.Charts
  alias RedEye.MarketData.Ticker

  @intervals ["15 minute", "30 minute", "1 hour", "4 hours", "1 day"]
  @def_interval "1 hour"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Charts.subscribe()

    {:ok,
     socket
     |> assign(interval: @def_interval)
     |> assign(interval_form: to_form(%{"interval" => @def_interval}))}
  end

  def get_from_bucket(symbol) do
    RedEye.MarketData.Bucket.get(:symbols, symbol, %Ticker{})
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    chart = Charts.get_chart!(id)

    symbol = chart.binance_symbol.symbol
    candles = RedEye.MarketData.list_binance_candles_for_chart(symbol, @def_interval)
    ticker = get_from_bucket(symbol)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_symbol, symbol)
     |> assign(:live_price, ticker.last_price)
     |> assign(:chart, chart)
     |> assign(:chart_data, candles)
     |> assign_new(:intervals, fn -> @intervals end)}
  end

  @impl true
  def handle_info(
        {:ticker, %Ticker{symbol: symbol} = ticker},
        %{assigns: %{current_symbol: symbol}} = socket
      ) do
    {:noreply,
     socket
     |> assign(:live_price, ticker.last_price)}
  end

  def handle_info({:ticker, %Ticker{}}, socket) do
    {:noreply, socket}
  end

  def handle_info({:chart_updated, _chart}, socket) do
    # todo ui to inform something updated
    {:noreply, socket}
  end

  @impl true
  def handle_event("candle:bars-info", %{"from" => _from, "to" => _to}, socket) do
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Chart"
  defp page_title(:edit), do: "Edit Chart"
end
