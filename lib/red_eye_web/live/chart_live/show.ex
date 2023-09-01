defmodule RedEyeWeb.ChartLive.Show do
  alias RedEye.MarketData.Ticker
  use RedEyeWeb, :live_view

  alias RedEye.Charts
  alias RedEye.Binance.Enums
  alias RedEye.MarketData.BinanceSpotCandle
  alias RedEye.MarketData.Ticker

  @intervals Enums.intervals()
  @default_interval "1h"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Charts.subscribe()

    {:ok,
     socket
     |> assign(interval: @intervals[@default_interval])}
  end

  def get_from_bucket(symbol) do
    RedEye.MarketData.Bucket.get(:symbols, symbol, %Ticker{})
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    chart = Charts.get_chart!(id)

    symbol = chart.binance_symbol.symbol
    candles = RedEye.MarketData.candle_chart(symbol, socket.assigns.interval)
    ticker = get_from_bucket(symbol)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_symbol, symbol)
     |> assign(:live_price, ticker.last_price)
     |> assign(:ticker, ticker)
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
     |> add_ticker(ticker)}
  end

  # Ignore tickers that aren't our current symbol
  def handle_info({:ticker, %Ticker{}}, socket) do
    {:noreply, socket}
  end

  def handle_info(
        {:kline, %BinanceSpotCandle{symbol: symbol} = candle},
        %{assigns: %{current_symbol: symbol}} = socket
      ) do
    {:noreply, socket |> add_candle(candle)}
  end

  def handle_info({:kline, %BinanceSpotCandle{}}, socket) do
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

  def market_direction(val) when is_number(val) do
    if val > 0, do: :up, else: :down
  end

  def market_direction(_val), do: :up

  defp add_candle(socket, candle) do
    candle =
      Map.take(candle, [:high, :low, :open, :close, :kline_open_time])
      |> Map.new(fn
        {:kline_open_time, time} -> {:time, time / 1000}
        anything -> anything
      end)

    push_event(socket, "update-candle", candle)
  end

  defp add_ticker(socket, ticker) do
    socket = assign(socket, :ticker, ticker)

    push_event(socket, "update-ticker", ticker)
  end

  defp page_title(:show), do: "Show Chart"
  defp page_title(:edit), do: "Edit Chart"
end
