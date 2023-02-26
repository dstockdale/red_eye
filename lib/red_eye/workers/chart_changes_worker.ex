defmodule RedEye.Workers.ChartChangesWorker do
  use Oban.Worker, queue: :data_import, unique: [period: 30]

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: :ok
  def perform(%Oban.Job{
        args: %{
          "chart_id" => chart_id,
          "earliest_timestamp" => earliest_timestamp
        }
      }) do
    chart = RedEye.Charts.get_chart!(chart_id)

    if is_nil(earliest_timestamp) do
      timestamp = RedEye.MarketApis.find_earliest_record(chart.binance_symbol.symbol)
      RedEye.Charts.update_chart(chart, %{earliest_timestamp: timestamp})
    else
      start_date =
        chart.earliest_timestamp
        |> DateTime.to_date()

      RedEye.MarketApis.import_binance_spot_candles_from_date(
        start_date,
        chart.binance_symbol.symbol,
        "1m"
      )
    end

    :ok
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(30)
end
