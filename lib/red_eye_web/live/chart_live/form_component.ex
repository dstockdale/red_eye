defmodule RedEyeWeb.ChartLive.FormComponent do
  use RedEyeWeb, :live_component

  alias RedEye.Charts

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage chart records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="chart-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :exchange}} type="text" label="Exchange" value="BinanceSpot" />
        <.input field={{f, :symbol}} type="text" label="Symbol" />
        <.input
          field={{f, :default_interval}}
          type="select"
          label="Default interval"
          options={RedEye.Charts.interval_options()}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Chart</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{chart: chart} = assigns, socket) do
    changeset = Charts.change_chart(chart)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"chart" => chart_params}, socket) do
    changeset =
      socket.assigns.chart
      |> Charts.change_chart(chart_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"chart" => chart_params}, socket) do
    save_chart(socket, socket.assigns.action, chart_params)
  end

  defp save_chart(socket, :edit, chart_params) do
    case Charts.update_chart(socket.assigns.chart, chart_params) do
      {:ok, _chart} ->
        {:noreply,
         socket
         |> put_flash(:info, "Chart updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_chart(socket, :new, chart_params) do
    case Charts.create_chart(chart_params) do
      {:ok, _chart} ->
        {:noreply,
         socket
         |> put_flash(:info, "Chart created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
