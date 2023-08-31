defmodule RedEyeWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At the first glance, this module may seem daunting, but its goal is
  to provide some core building blocks in your application, such modals,
  tables, and forms. The components are mostly markup and well documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component
  use PetalComponents

  alias Phoenix.LiveView.JS
  import RedEyeWeb.Gettext
  import Twix

  # @doc """
  # Renders a modal.

  # ## Examples

  #     <.modal id="confirm-modal">
  #       This is a modal.
  #     </.modal>

  # JS commands may be passed to the `:on_cancel` to configure
  # the closing/cancel event, for example:

  #     <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
  #       This is another modal.
  #     </.modal>

  # """
  # attr(:id, :string, required: true)
  # attr(:show, :boolean, default: false)
  # attr(:on_cancel, JS, default: %JS{})
  # slot(:inner_block, required: true)

  # def modal(assigns) do
  #   ~H"""
  #   <div
  #     id={@id}
  #     phx-mounted={@show && show_modal(@id)}
  #     phx-remove={hide_modal(@id)}
  #     data-cancel={JS.exec(@on_cancel, "phx-remove")}
  #     class="relative z-50 hidden"
  #   >
  #     <div id={"#{@id}-bg"} class="fixed inset-0 transition-opacity bg-zinc-50/90" aria-hidden="true" />
  #     <div
  #       class="fixed inset-0 overflow-y-auto"
  #       aria-labelledby={"#{@id}-title"}
  #       aria-describedby={"#{@id}-description"}
  #       role="dialog"
  #       aria-modal="true"
  #       tabindex="0"
  #     >
  #       <div class="flex items-center justify-center min-h-full">
  #         <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
  #           <.focus_wrap
  #             id={"#{@id}-container"}
  #             phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
  #             phx-key="escape"
  #             phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
  #             class="relative hidden transition bg-white shadow-lg shadow-zinc-700/10 ring-zinc-700/10 rounded-2xl p-14 ring-1"
  #           >
  #             <div class="absolute top-6 right-5">
  #               <button
  #                 phx-click={JS.exec("data-cancel", to: "##{@id}")}
  #                 type="button"
  #                 class="flex-none p-3 -m-3 opacity-20 hover:opacity-40"
  #                 aria-label={gettext("close")}
  #               >
  #                 <.icon name="hero-x-mark-solid" class="w-5 h-5" />
  #               </button>
  #             </div>
  #             <div id={"#{@id}-content"}>
  #               <%= render_slot(@inner_block) %>
  #             </div>
  #           </.focus_wrap>
  #         </div>
  #       </div>
  #     </div>
  #   </div>
  #   """
  # end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr(:id, :string, default: "flash", doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name={:information_circle} mini class="w-4 h-4" />
        <.icon :if={@kind == :error} name={:exclamation_circle} mini class="w-4 h-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="absolute p-2 group top-1 right-1" aria-label={gettext("close")}>
        <.icon name={:x_mark} solid class="w-5 h-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} title="Success!" flash={@flash} />
    <.flash kind={:error} title="Error!" flash={@flash} />
    <.flash
      id="client-error"
      kind={:error}
      title="We can't find the internet"
      phx-disconnected={show(".phx-client-error #client-error")}
      phx-connected={hide("#client-error")}
      hidden
    >
      Attempting to reconnect <.icon name={:arrow_path} class="w-3 h-3 ml-1 animate-spin" />
    </.flash>

    <.flash
      id="server-error"
      kind={:error}
      title="Something went wrong!"
      phx-disconnected={show(".phx-server-error #server-error")}
      phx-connected={hide("#server-error")}
      hidden
    >
      Hang in there while we get back on track
      <.icon name={:arrow_path} class="w-3 h-3 ml-1 animate-spin" />
    </.flash>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr(:for, :any, required: true, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")
  attr(:class, :string, default: nil)

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class={tw(["mt-10 space-y-8 bg-white", @class])}>
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="flex items-center justify-between gap-6 mt-2">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  # @doc """
  # Renders a button.

  # ## Examples

  #     <.button>Send!</.button>
  #     <.button phx-click="go" class="ml-2">Send!</.button>
  # """

  # # attr(:type, :string, default: nil)
  # # attr(:class, :string, default: nil)
  # # attr(:rest, :global, include: ~w(disabled form name value))

  # # slot(:inner_block, required: true)

  # def button(assigns) do
  #   ~H"""
  #   <button
  #     type={@type}
  #     class={[
  #       "phx-submit-loading:opacity-75 rounded-md bg-indigo-500 px-2.5 py-1.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-400",
  #       "focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500",
  #       @class
  #     ]}
  #     {@rest}
  #   >
  #     <%= render_slot(@inner_block) %>
  #   </button>
  #   """
  # end

  # @doc """
  # Renders an input with label and error messages.

  # A `Phoenix.HTML.FormField` may be passed as argument,
  # which is used to retrieve the input name, id, and values.
  # Otherwise all attributes may be passed explicitly.

  # ## Types

  # This function accepts all HTML input types, considering that:

  #   * You may also set `type="select"` to render a `<select>` tag

  #   * `type="checkbox"` is used exclusively to render boolean values

  #   * For live file uploads, see `Phoenix.Component.live_file_input/1`

  # See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  # for more information.

  # ## Examples

  #     <.input field={@form[:email]} type="email" />
  #     <.input name="my-input" errors={["oh no!"]} />
  # """

  # attr :id, :any, default: nil
  # attr :name, :any
  # attr :label, :string, default: nil
  # attr :value, :any

  # attr :type, :string,
  #   default: "text",
  #   values: ~w(checkbox color date datetime-local email file hidden month number password
  #              range radio search select tel text textarea time url week)

  # attr :field, Phoenix.HTML.FormField,
  #   doc: "a form field struct retrieved from the form, for example: @form[:email]"

  # attr :errors, :list, default: []
  # attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  # attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  # attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  # attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  # attr :rest, :global,
  #   include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
  #               multiple pattern placeholder readonly required rows size step)

  # attr :class, :string, default: ""

  # slot :inner_block

  # def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
  #   assigns
  #   |> assign(field: nil, id: assigns.id || field.id)
  #   |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
  #   |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
  #   |> assign_new(:value, fn -> field.value end)
  #   |> input()
  # end

  # def input(%{type: "checkbox", value: value} = assigns) do
  #   assigns =
  #     assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

  #   ~H"""
  #   <div phx-feedback-for={@name}>
  #     <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
  #       <input type="hidden" name={@name} value="false" />
  #       <input
  #         type="checkbox"
  #         id={@id}
  #         name={@name}
  #         value="true"
  #         checked={@checked}
  #         class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
  #         {@rest}
  #       />
  #       <%= @label %>
  #     </label>
  #     <.error :for={msg <- @errors}><%= msg %></.error>
  #   </div>
  #   """
  # end

  # def input(%{type: "select"} = assigns) do
  #   ~H"""
  #   <div phx-feedback-for={@name}>
  #     <.label for={@id}><%= @label %></.label>
  #     <select
  #       id={@id}
  #       name={@name}
  #       class="block w-full mt-2 bg-white border border-gray-300 rounded-md shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
  #       multiple={@multiple}
  #       {@rest}
  #     >
  #       <option :if={@prompt} value=""><%= @prompt %></option>
  #       <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
  #     </select>
  #     <.error :for={msg <- @errors}><%= msg %></.error>
  #   </div>
  #   """
  # end

  # def input(%{type: "textarea"} = assigns) do
  #   ~H"""
  #   <div phx-feedback-for={@name}>
  #     <.label for={@id}><%= @label %></.label>
  #     <textarea
  #       id={@id}
  #       name={@name}
  #       class={[
  #         "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
  #         "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
  #         @errors == [] && "border-zinc-300 focus:border-zinc-400",
  #         @errors != [] && "border-rose-400 focus:border-rose-400"
  #       ]}
  #       {@rest}
  #     ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
  #     <.error :for={msg <- @errors}><%= msg %></.error>
  #   </div>
  #   """
  # end

  # # All other inputs text, datetime-local, url, password, etc. are handled here...
  # def input(assigns) do
  #   ~H"""
  #   <div phx-feedback-for={@name}>
  #     <.label for={@id}><%= @label %></.label>
  #     <input
  #       type={@type}
  #       name={@name}
  #       id={@id}
  #       value={Phoenix.HTML.Form.normalize_value(@type, @value)}
  #       class={
  #         tw([
  #           "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
  #           "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
  #           @errors == [] && "border-zinc-300 focus:border-zinc-400",
  #           @errors != [] && "border-rose-400 focus:border-rose-400",
  #           @class
  #         ])
  #       }
  #       {@rest}
  #     />
  #     <.error :for={msg <- @errors}><%= msg %></.error>
  #   </div>
  #   """
  # end

  @doc """
  Renders a label.
  """
  attr(:for, :string, default: nil)
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot(:inner_block, required: true)

  def error(assigns) do
    ~H"""
    <p class="flex gap-3 mt-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name={:exclamation_circle} mini class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr(:class, :string, default: nil)

  slot(:inner_block, required: true)
  slot(:subtitle)
  slot(:actions)

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600 dark:text-zinc-300">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)
  attr(:row_id, :any, default: nil, doc: "the function for generating the row id")
  attr(:row_click, :any, default: nil, doc: "the function for handling phx-click on each row")

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"
  )

  slot :col, required: true do
    attr(:label, :string)
    attr(:class, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column")

  def datatable(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="mt-10 -mx-4 ring-1 ring-gray-300 dark:ring-gray-500 sm:mx-0 sm:rounded-lg">
      <table class="min-w-full divide-y divide-gray-300 dark:divide-gray-500">
        <thead>
          <tr>
            <th
              :for={col <- @col}
              class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-white lg:table-cell"
            >
              <%= col[:label] %>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative text-sm leading-6 border-t divide-y divide-zinc-100 dark:divide-gray-500 border-zinc-200 dark:border-zinc-500 text-zinc-700 dark:text-zinc-300"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class="group hover:bg-zinc-50 dark:hover:bg-zinc-600"
          >
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={[
                "relative p-0",
                @row_click && "hover:cursor-pointer",
                col[:class] && col[:class]
              ]}
            >
              <div class="block px-3 py-4">
                <span class={["relative", i == 0 && "font-semibold text-zinc-900 dark:text-zinc-300"]}>
                  <%= render_slot(col, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="flex-none w-1/4 text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr(:navigate, :any, required: true)
  slot(:inner_block, required: true)

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name={:arrow_left} solid class="w-3 h-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  attr(:size, :integer, default: 20)

  def red_eye_logo(assigns) do
    ~H"""
    <svg
      viewBox="0 0 100"
      xmlns="http://www.w3.org/2000/svg"
      xml:space="preserve"
      width={@size}
      height={@size}
    >
      <path d="M90.852 144.963c13.73-16.416 35.063-26.681 58.745-26.03 23.685.652 44.421 12.074 57.227 29.22-13.728 16.414-35.061 26.68-58.745 26.028-23.684-.651-44.419-12.074-57.227-29.218m-11.917-.36c13.985 22.601 39.426 38.071 68.888 38.881 29.462.81 55.717-13.237 70.923-35.035-13.984-22.629-39.427-38.118-68.889-38.928-29.462-.811-55.715 13.256-70.922 35.082" />
      <circle
        cx="148.558"
        cy="146.242"
        transform="rotate(-.876 148.839 146.509)"
        fill="#de0700"
        stroke-width="5"
        stroke="#fb5a5a"
        r="17.171"
      />
    </svg>
    """
  end

  attr(:asset, :string, required: true)

  def crypto_icon(assigns) do
    ~H"""
    <div class="inline-block w-8 h-8">
      <i
        style={"background-image: url(/assets/crypto/#{String.downcase(@asset)}.svg)"}
        class="block w-8 h-8 bg-no-repeat"
      />
    </div>
    """
  end

  attr(:base_asset, :string, required: true)
  attr(:quote_asset, :string, required: true)

  def crypto_icons(assigns) do
    ~H"""
    <div class="relative inline-block h-8 w-11">
      <i
        style={"background-image: url(/assets/crypto/#{String.downcase(@quote_asset)}.svg)"}
        class="absolute right-0 block w-8 h-8 bg-no-repeat"
      />
      <i
        style={"background-image: url(/assets/crypto/#{String.downcase(@base_asset)}.svg)"}
        class="absolute left-0 block w-8 h-8 bg-no-repeat"
      />
    </div>
    """
  end

  # @doc """
  # Renders a [Heroicon](https://heroicons.com).

  # Heroicons come in three styles – outline, solid, and mini.
  # By default, the outline style is used, but solid and mini may
  # be applied by using the `-solid` and `-mini` suffix.

  # You can customize the size and colors of the icons by setting
  # width, height, and background color classes.

  # Icons are extracted from your `assets/vendor/heroicons` directory and bundled
  # within your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  # ## Examples

  #     <.icon name="hero-x-mark-solid" />
  #     <.icon name="hero-arrow-path" class="w-3 h-3 ml-1 animate-spin" />
  # """
  # attr(:name, :string, required: true)
  # attr(:class, :string, default: nil)

  # def icon(%{name: "hero-" <> _} = assigns) do
  #   ~H"""
  #   <span class={[@name, @class]} />
  #   """
  # end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  # def show_modal(js \\ %JS{}, id) when is_binary(id) do
  #   js
  #   |> JS.show(to: "##{id}")
  #   |> JS.show(
  #     to: "##{id}-bg",
  #     transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
  #   )
  #   |> show("##{id}-container")
  #   |> JS.add_class("overflow-hidden", to: "body")
  #   |> JS.focus_first(to: "##{id}-content")
  # end

  # def hide_modal(js \\ %JS{}, id) do
  #   js
  #   |> JS.hide(
  #     to: "##{id}-bg",
  #     transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
  #   )
  #   |> hide("##{id}-container")
  #   |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
  #   |> JS.remove_class("overflow-hidden", to: "body")
  #   |> JS.pop_focus()
  # end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(RedEyeWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(RedEyeWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  attr(:id, :string, required: true)
  attr(:from, :string, required: true)
  attr(:size, :string, default: "w-4 h-4")

  attr(:class, :string, default: "p-2 text-zinc-900 hover:bg-gray-200 focus:bg-gray-100")

  def clippy_button(assigns) do
    ~H"""
    <button type="button" id={@id} data-from={@from} phx-hook="Clippy" class={@class}>
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class={@size}>
        <path
          fill-rule="evenodd"
          d="M13.887 3.182c.396.037.79.08 1.183.128C16.194 3.45 17 4.414 17 5.517V16.75A2.25 2.25 0 0114.75 19h-9.5A2.25 2.25 0 013 16.75V5.517c0-1.103.806-2.068 1.93-2.207.393-.048.787-.09 1.183-.128A3.001 3.001 0 019 1h2c1.373 0 2.531.923 2.887 2.182zM7.5 4A1.5 1.5 0 019 2.5h2A1.5 1.5 0 0112.5 4v.5h-5V4z"
          clip-rule="evenodd"
        />
      </svg>
    </button>
    """
  end

  def live_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns =
      assigns
      |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
      |> assign(:live_select_opts, assigns_to_attributes(assigns, [:errors, :label]))

    ~H"""
    <div phx-feedback-for={@field.name}>
      <.label for={@field.id}><%= @label %></.label>
      <LiveSelect.live_select
        field={@field}
        text_input_class={[
          "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
          "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5",
          @errors != [] && "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"
        ]}
        {@live_select_opts}
      />

      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  attr(:time, :any, required: true)
  attr(:format, :string, default: "%B %d, %Y")
  attr(:class, :string, default: "")

  def time(%{time: nil} = assigns), do: render_nothing(assigns)

  def time(assigns) do
    assigns =
      assigns
      |> assign(
        :label,
        Timex.Format.DateTime.Formatter.format!(assigns.time, assigns.format, :strftime)
      )

    ~H"""
    <time time={@time} class={@class}><%= @label %></time>
    """
  end

  defp render_nothing(assigns) do
    ~H"""

    """
  end

  def deal(assigns) do
    ~H"""
    <div class="h-full w-[280px] border shadow-md dark:shadow-inner dark:shadow-blue-100/10 border-gray-200 dark:border-gray-600 hover:border-gray-300 px-3 py-2 rounded-md bg-slate-50 dark:bg-slate-800">
      <div class="flex gap-2">
        <div class="flex items-center flex-grow gap-2">
          <h2 class="text-sm font-bold text-gray-900 dark:text-gray-100"><%= @symbol %></h2>
          <div class="text-sm font-bold text-green-600">LONG</div>
          <div class="text-sm font-bold text-gray-800 dark:text-gray-100">
            <svg
              class="w-4 h-4 rotate-180"
              aria-hidden="true"
              fill="currentColor"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 320 512"
            >
              <path d="M9.39 265.4l127.1-128C143.6 131.1 151.8 128 160 128s16.38 3.125 22.63 9.375l127.1 128c9.156 9.156 11.9 22.91 6.943 34.88S300.9 320 287.1 320H32.01c-12.94 0-24.62-7.781-29.58-19.75S.2333 274.5 9.39 265.4z" />
            </svg>
          </div>
          <div class="text-sm font-bold text-green-600">0.3%</div>
        </div>
        <.button size="xs" icon={:pause} color="gray" />
      </div>
      <div class="flex gap-2">
        <span class="text-xs font-semibold text-yellow-400">Binance</span>
        <span class="text-xs font-semibold dark:text-slate-100 text-slate-800">Gann Swing</span>
      </div>
      <div class="flex gap-2">
        <div class="text-sm font-medium dark:text-slate-200 text-slate-800">
          P $2,6700.00 @ $19.78
        </div>
      </div>
      <div class="flex gap-2">
        <div class="text-sm font-medium text-red-500">
          SL $18.32
        </div>
        <div class="text-sm font-medium text-blue-500">
          R1 $462.11
        </div>
      </div>
    </div>
    """
  end
end
