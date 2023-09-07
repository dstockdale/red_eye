defmodule RedEyeWeb.ChartLive.Show do
  alias RedEye.MarketData.Ticker
  use RedEyeWeb, :live_view

  alias RedEyeWeb.Presence
  alias RedEye.Charts
  alias RedEye.MarketData.BinanceSpotCandle
  alias RedEye.MarketData.Ticker

  @impl true

  def mount(_param, _session, %{assigns: %{current_user: current_user}} = socket)
      when is_connected?(socket) do
    join_page(current_user, socket)

    Presence.chart_subscribe()
    Charts.subscribe()
    RedEye.MarketData.subscribe()

    {:ok,
     socket
     |> assign(:users, %{})
     |> handle_joins(Presence.list("chart-view"))}
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # interval = socket.assigns.current_user.preferences.chart_interval
    interval = "1h"
    chart = Charts.get_chart!(id)
    symbol = chart.binance_symbol.symbol
    candles = RedEye.MarketData.candle_chart(symbol, interval)
    ticker = get_from_bucket(symbol)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:current_symbol, symbol)
     |> assign(:live_price, ticker.last_price)
     |> assign(:ticker, ticker)
     |> assign(:chart, chart)
     |> assign(:chart_data, candles)
     |> assign(:interval, interval)}
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
        {:kline, %BinanceSpotCandle{symbol: symbol, interval: interval} = candle},
        %{assigns: %{current_symbol: symbol, interval: interval}} = socket
      ) do
    {:noreply, add_candle(socket, candle)}
  end

  def handle_info({:kline, %BinanceSpotCandle{}}, socket) do
    {:noreply, socket}
  end

  def handle_info({:chart_updated, chart}, socket) do
    # todo ui to inform something updated
    IO.inspect(chart, label: ":chart_updated")
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {
      :noreply,
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    }
  end

  def handle_info({:candle_inserted, %RedEye.MarketData.BinanceSpotCandle{} = candle}, socket) do
    # {:noreply, add_candle(socket, candle)}
    {:noreply, socket}
  end

  @impl true
  def handle_event("candle:bars-info", %{"from" => _from, "to" => _to}, socket) do
    {:noreply, socket}
  end

  def handle_event("set-interval", %{"interval" => value}, socket) do
    {:noreply, assign(socket, interval: value)}
  end

  defp market_direction(val) when is_number(val) do
    if val > 0, do: :up, else: :down
  end

  defp market_direction(_val), do: :up

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      assign(socket, :users, Map.put(socket.assigns.users, user, meta))
    end)
  end

  defp handle_leaves(socket, leaves) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end

  defp add_candle(socket, candle) do
    candle =
      Map.take(candle, [:high, :low, :open, :close, :unix_time])
      |> Map.new(fn
        {:unix_time, time} -> {:time, time / 1000}
        anything -> anything
      end)

    push_event(socket, "update-candle", candle)
  end

  defp add_ticker(socket, ticker) do
    socket = assign(socket, :ticker, ticker)

    push_event(socket, "update-ticker", ticker)
  end

  defp get_from_bucket(symbol) do
    RedEye.MarketData.Bucket.get(:symbols, symbol, %Ticker{})
  end

  defp join_page(user, socket) do
    {:ok, _} =
      Presence.track(self(), "chart-view", user.id, %{
        name: user.email,
        joined_at: :os.system_time(:seconds)
      })

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Chart"
  defp page_title(:edit), do: "Edit Chart"
end
