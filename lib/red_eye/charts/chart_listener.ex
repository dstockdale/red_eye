defmodule RedEye.Charts.ChartListener do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(_opts) do
    RedEye.Charts.subscribe()

    {:ok, %{}}
  end

  def handle_info({:chart_created, %RedEye.Charts.Chart{} = chart}, state) do
    default_start_date()
    |> backfill_data(chart)

    {:noreply, state}
  end

  def handle_info({:chart_updated, %RedEye.Charts.Chart{} = chart}, state) do
    default_start_date()
    |> backfill_data(chart)

    {:noreply, state}
  end

  defp default_start_date do
    DateTime.utc_now()
    |> DateTime.add(-365, :day)
    |> DateTime.to_date()
  end

  defp backfill_data(start_date, chart) do
    chart = RedEye.Charts.get_chart!(chart.id, [:binance_symbol])

    RedEye.MarketApis.import_binance_spot_candles_from_date(
      start_date,
      chart.binance_symbol.symbol,
      "1m"
    )
  end
end
