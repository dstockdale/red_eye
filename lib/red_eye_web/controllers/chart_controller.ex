defmodule RedEyeWeb.ChartController do
  use RedEyeWeb, :controller

  action_fallback(RedEyeWeb.FallbackController)

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, %{"symbol" => symbol, "interval" => interval, "chart_type" => "candle"}) do
    chart = RedEye.MarketData.candle_chart(symbol, interval)

    render(conn, :index, chart: chart)
  end

  def index(conn, %{"symbol" => symbol, "interval" => interval, "chart_type" => "swing"} = params) do
    opts = handle_params(params)
    chart = RedEye.MarketData.swing_chart(symbol, interval, opts)

    render(conn, :index, chart: chart)
  end

  def handle_params(params) do
    symbol = Map.get(params, "symbol")

    case Map.fetch(params, "start_time") do
      {:ok, time} ->
        start_time = String.to_integer(time) |> DateTime.from_unix!()
        end_time = Map.get(params, "end_time") |> String.to_integer() |> DateTime.from_unix!()

        %{
          "start_time" => start_time,
          "end_time" => end_time
        }

      :error ->
        default_opts(symbol)
    end
  end

  def default_opts(symbol) do
    end_time = RedEye.MarketData.most_recent_candle(symbol)
    start_time = DateTime.add(end_time, -10, :day)

    %{
      "start_time" => start_time,
      "end_time" => end_time
    }
  end
end
