defmodule RedEye.Workers.ChartChangesWorker do
  use Oban.Worker, queue: :data_import

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: :ok
  def perform(%Oban.Job{
        args: %{
          "chart_id" => chart_id
        }
      }) do
    chart = RedEye.Charts.get_chart!(chart_id)
    handle_chart(chart, chart.earliest_timestamp)

    :ok
  end

  def handle_chart(%RedEye.Charts.Chart{} = chart, earliest_timestamp)
      when is_nil(earliest_timestamp) do
    timestamp = RedEye.MarketApis.find_earliest_record(chart.binance_symbol.symbol)
    RedEye.Charts.update_chart(chart, %{earliest_timestamp: timestamp})
  end

  def handle_chart(%RedEye.Charts.Chart{} = chart, %DateTime{} = earliest_timestamp) do
    start_date =
      earliest_timestamp
      |> DateTime.to_date()

    RedEye.MarketApis.import_binance_spot_candles_from_date(
      start_date,
      chart.binance_symbol.symbol,
      "1m"
    )
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)
end
