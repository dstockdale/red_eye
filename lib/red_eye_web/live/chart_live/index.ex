defmodule RedEyeWeb.ChartLive.Index do
  use RedEyeWeb, :live_view

  alias RedEye.Charts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :charts, Charts.list_charts([:binance_symbol]))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    chart = Charts.get_chart!(id)
    {:ok, _} = Charts.delete_chart(chart)

    {:noreply, stream_delete(socket, :charts, chart)}
  end
end
