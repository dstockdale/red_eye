defmodule RedEye.Charts.ChartListener do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def init(_opts) do
    RedEye.Charts.subscribe()

    {:ok, %{}}
  end

  def handle_info({:chart_created, %RedEye.Charts.Chart{id: chart_id}}, state) do
    RedEye.Workers.ChartChangesWorker.new(%{chart_id: chart_id})

    {:noreply, state}
  end

  def handle_info({:chart_updated, %RedEye.Charts.Chart{id: chart_id}}, state) do
    RedEye.Workers.ChartChangesWorker.new(%{chart_id: chart_id})

    {:noreply, state}
  end
end
