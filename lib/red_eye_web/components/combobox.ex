defmodule RedEyeWeb.Combobox do
  use RedEyeWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:value, fn -> "" end)
     |> assign_new(:options, fn -> assigns.options end)
     |> assign_new(:search, fn -> "" end)
     |> assign_new(:cid, fn -> assigns.cid end)}
  end

  attr :cid, :any
  attr :id, :any
  attr :field, :any

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="relative mt-2">
      <.search field={@field} phx-keyup="find-symbol" phx-target={@cid} />
      <button
        type="button"
        class="absolute inset-y-0 right-0 flex items-center px-2 rounded-r-md focus:outline-none"
      >
        <svg class="w-5 h-5 text-gray-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path
            fill-rule="evenodd"
            d="M10 3a.75.75 0 01.55.24l3.25 3.5a.75.75 0 11-1.1 1.02L10 4.852 7.3 7.76a.75.75 0 01-1.1-1.02l3.25-3.5A.75.75 0 0110 3zm-3.76 9.2a.75.75 0 011.06.04l2.7 2.908 2.7-2.908a.75.75 0 111.1 1.02l-3.25 3.5a.75.75 0 01-1.1 0l-3.25-3.5a.75.75 0 01.04-1.06z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
      <ul
        class="absolute z-10 w-full py-1 mt-1 overflow-auto text-base bg-white rounded-md shadow-lg max-h-60 ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm"
        id={"#{@id}-options"}
        role="listbox"
        phx-update="replace"
      >
        <.combobox_option :for={option <- @options} option={option} id={option.id} cid={@cid} />
      </ul>
    </div>
    """
  end

  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  attr :cid, :any

  def search(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def search(assigns) do
    ~H"""
    <h2>Thing</h2>
    <input
      id={"#{@id}_label"}
      type="text"
      class="w-full rounded-md border-0 bg-white py-1.5 pl-3 pr-12 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
      role="combobox"
      aria-controls={"#{@id}-options"}
      aria-expanded="false"
      autocomplete="off"
      spellcheck="off"
      name={@name}
      value={@value}
    />
    <input id={@id} type="hidden" name={@name} value={@value} />
    """
  end

  def combobox_option(assigns) do
    ~H"""
    <li
      class="relative py-2 pl-3 text-gray-900 cursor-default select-none pr-9"
      id="option-0"
      role="option"
      tabindex="-1"
      id={@id}
      phx-value-symbol={@option.symbol}
      phx-value-id={@option.id}
      phx-target={@cid}
      phx-click="pick-symbol"
    >
      <!-- Selected: "font-semibold" -->
      <span class="block truncate"><%= @option.symbol %></span>
      <!--
            Checkmark, only display for selected option.

            Active: "text-white", Not Active: "text-indigo-600"
          -->
      <span class="absolute inset-y-0 right-0 flex items-center pr-4 text-indigo-600">
        <svg class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path
            fill-rule="evenodd"
            d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
            clip-rule="evenodd"
          />
        </svg>
      </span>
    </li>
    """
  end
end
