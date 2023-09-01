defmodule RedEyeWeb.ChartLive.Index do
  use RedEyeWeb, :live_view

  alias RedEye.Charts
  alias RedEye.MarketData.Ticker
  alias RedEye.MarketData.BinanceSpotCandle

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Charts.subscribe()
    charts = Charts.list_charts([:binance_symbol])

    {:ok, stream(socket, :charts, charts) |> assign(:charts_cache, charts)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    chart = Charts.get_chart!(id)
    {:ok, _} = Charts.delete_chart(chart)

    {:noreply, stream_delete(socket, :charts, chart)}
  end

  @impl true
  def handle_info({:ticker, %Ticker{symbol: symbol} = ticker}, socket) do
    chart = find_chart(symbol, socket)
    updated_chart = put_in(chart.ticker, ticker)

    {:noreply, stream_insert(socket, :charts, updated_chart)}
  end

  # Do nothing with this, for now...
  def handle_info({:kline, %BinanceSpotCandle{}}, socket) do
    {:noreply, socket}
  end

  def market_direction(val) when is_number(val) do
    if val > 0, do: :up, else: :down
  end

  defp find_chart(symbol, socket) do
    socket.assigns.charts_cache
    |> Enum.find(fn chart -> chart.binance_symbol.symbol == symbol end)
  end
end
