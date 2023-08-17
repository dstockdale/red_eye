defmodule RedEyeWeb.DashboardLive.Index do
  use RedEyeWeb, :live_view

  alias RedEye.Charts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :charts, Charts.list_charts([:binance_symbol]))}
  end
end
