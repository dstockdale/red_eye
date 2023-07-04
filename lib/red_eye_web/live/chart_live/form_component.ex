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
        for={@form}
        id="chart-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:exchange]} type="select" options={@exchanges} label="Exchange" />

        <.live_select
          field={@form[:binance_symbol_id]}
          mode={:single}
          label="Symbol"
          options={[]}
          phx-target={@myself}
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
     |> assign_new(:exchanges, fn -> RedEye.Charts.exchange_options() end)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"chart" => chart_params}, socket) do
    changeset =
      socket.assigns.chart
      |> Charts.change_chart(chart_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"chart" => chart_params}, socket) do
    save_chart(socket, socket.assigns.action, chart_params)
  end

  @impl true
  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    options = RedEye.MarketData.search_binance_symbols(text)

    send_update(LiveSelect.Component, id: live_select_id, options: options)

    {:noreply, socket}
  end

  defp save_chart(socket, :edit, chart_params) do
    case Charts.update_chart(socket.assigns.chart, chart_params) do
      {:ok, chart} ->
        notify_parent({:saved, chart})

        {:noreply,
         socket
         |> put_flash(:info, "Chart updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_chart(socket, :new, chart_params) do
    case Charts.create_chart(chart_params) do
      {:ok, chart} ->
        notify_parent({:saved, chart})

        {:noreply,
         socket
         |> put_flash(:info, "Chart created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
