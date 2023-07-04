defmodule RedEyeWeb.ChartLive.New do
  use RedEyeWeb, :live_view

  alias RedEye.Charts.Chart

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "New Chart")
     |> assign(:chart, %Chart{})}
  end

  @impl true
  def handle_event("change", params, socket) do
    IO.inspect(params)

    {:noreply, socket}
  end
end
