defmodule RedEyeWeb.UserSettingsLive do
  use RedEyeWeb, :live_view

  alias RedEye.Accounts

  def toggle_flexbox(js \\ %JS{}) do
    js
    |> JS.remove_class(
      "hidden",
      to: "#app-auth-device.hidden"
    )
    |> JS.add_class(
      "flex",
      to: "#app-auth-device:not(.hidden)"
    )
  end

  def render(assigns) do
    ~H"""
    <.h2 class="text-center">
      Account Settings
    </.h2>

    <.accordion class="w-full mt-10">
      <:item heading="Authenticator App">
      <%= if is_nil(@current_user.totp_confirmed_at) do %>
        <div class="leading-8 text-md text-zinc-700" id="app-auth-device-intro">
          <.p>
            You need to use an authenticator app to get full access to the system.
          </.p>
          <.button
            class="mt-6 bg-amber-400 text-slate-800 hover:bg-amber-500"
            size="xs"
            with_icon={true}
            phx-click={
              JS.toggle(to: "#app-auth-device", display: "flex")
              |> JS.toggle(to: "#app-auth-device-intro")
            }
          >
            Setup Authentication App
            <.icon name={:play} solid class="w-3 h-3" />
          </.button>
        </div>

        <div class="hidden gap-4" id="app-auth-device">
          <div>
            <%= raw(@qrcode) %>
          </div>
          <div class="flex-grow" id="otp_form_step1">
            <p class="text-sm leading-6 text-zinc-600">Scan this QR code in the authenticator app</p>

            <div class="flex items-center max-w-sm mt-10" data-otp-setup="intro">
              <p tabindex="-1" id="otp-secret-text" class="flex-grow text-xs">
                <%= @otp_secret %>
              </p>
              <.clippy_button id="clippy-btn" size="w-3 w-3" from="otp-secret-text" />
            </div>

            <p class="text-sm leading-6 text-zinc-600">
              If you are unable to scan the OR code, please enter this code manually into the app.
            </p>

            <button
              class="inline-flex items-center gap-1 px-2 py-1 mt-6 text-xs font-semibold leading-4 rounded-sm text-zinc-800 bg-amber-400"
              phx-click={JS.toggle(to: "#otp_form_step2") |> JS.toggle(to: "#otp_form_step1")}
            >
              <span class="flex-grow">Next</span>
              <.icon name={:play} solid class="w-3 h-3" />
            </button>
          </div>
          <div id="otp_form_step2" class="hidden">
            <.simple_form
              class="mt-2"
              for={@otp_form}
              id="otp_form"
              phx-submit="update_otp"
              phx-change="validate_otp"
            >
              <.input
                field={@otp_form[:otp_code]}
                type="text"
                inputmode="numeric"
                pattern="[0-9]*"
                maxlength="6"
                label="OTP Code"
                max={999_999}
                phx-debounce="blur"
                autocomplete="off"
                spellcheck="off"
                class="w-32"
                required
              />
            </.simple_form>
          </div>
        </div>
      <% else %>
        <.p>Added: <.time time={@current_user.totp_confirmed_at} /></.p>

        <.form for={@reset_otp_form} phx-submit="reset_otp_secret" class="mt-6">
          <.button icon={:trash} color="secondary" label="Reset Authentication App" size="xs" data-confirm="Are  you sure? You'll have to setup a new Auth application" />
        </.form>
      <% end %>
      </:item>

      <:item heading="Change Email">
        <.p id="app-email-change-intro">
          You can change your email but you'll need to reconfirm the address after you do this.
          <button
            class="flex items-center gap-1 px-2 py-1 mt-6 text-xs font-semibold leading-4 rounded-sm text-zinc-800 bg-amber-400"
            phx-click={JS.toggle(to: "#app-email-change") |> JS.toggle(to: "#app-email-change-intro")}
          >
            <span class="flex-grow">Change Email</span>
            <.icon name={:play} solid class="w-3 h-3" />
          </button>
        </.p>

        <div class="hidden space-y-12 divide-y" id="app-email-change">
          <div>
            <.simple_form
              for={@email_form}
              id="email_form"
              phx-submit="update_email"
              phx-change="validate_email"
            >
              <.input field={@email_form[:email]} type="email" label="Email" required />
              <.input
                field={@email_form[:current_password]}
                name="current_password"
                id="current_password_for_email"
                type="password"
                label="Current password"
                value={@email_form_current_password}
                required
              />
              <:actions>
                <.button phx-disable-with="Changing...">Change Email</.button>
              </:actions>
            </.simple_form>
          </div>
        </div>
      </:item>

      <:item heading="Change Password">
      <.p id="app-password-change-intro">
      If you need to change your password remember it must be 12 chars minimum, contain both uppercase and lowercase letters
      as well as numbers and at least one non alpha numeric character.
      <button
        class="flex items-center gap-1 px-2 py-1 mt-6 -mr-1 text-xs font-semibold leading-4 rounded-sm text-zinc-800 bg-amber-400"
        phx-click={
          JS.toggle(to: "#app-password-change")
          |> JS.toggle(to: "#app-password-change-intro")
        }
      >
        <span class="flex-grow">Change Password</span>
        <.icon name={:play} solid class="w-3 h-3" />
      </button>
    </.p>

    <div id="app-password-change" class="hidden">
      <.simple_form
        for={@password_form}
        id="password_form"
        action={~p"/users/log_in?_action=password_updated"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <.input
          field={@password_form[:email]}
          type="hidden"
          id="hidden_user_email"
          value={@current_email}
        />
        <.input field={@password_form[:password]} type="password" label="New password" required />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
        />
        <.input
          field={@password_form[:current_password]}
          name="current_password"
          type="password"
          label="Current password"
          id="current_password_for_password"
          value={@current_password}
          required
        />
        <:actions>
          <.button phx-disable-with="Changing...">Change Password</.button>
        </:actions>
      </.simple_form>
    </div>
      </:item>
    </.accordion>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    otp_changeset = Accounts.change_otp(user)
    reset_otp_changeset = Accounts.change_reset_otp(user)
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    qrcode =
      NimbleTOTP.otpauth_uri("RedEye:#{user.email}", user.totp_secret, issuer: "RedEye")
      |> EQRCode.encode()
      |> EQRCode.svg(width: 200)

    otp_secret = user.totp_secret |> Base.encode32(padding: false)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:otp_form, to_form(otp_changeset))
      |> assign(:reset_otp_form, to_form(reset_otp_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:qrcode, qrcode)
      |> assign(:otp_secret, otp_secret)

    {:ok, socket}
  end

  def handle_event("validate_otp", params, socket) do
    %{"user" => user_params} = params

    otp_form =
      socket.assigns.current_user
      |> Accounts.change_otp(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, otp_form: otp_form)}
  end

  def handle_event("update_otp", params, socket) do
    %{"user" => user_params} = params

    case Accounts.update_confirm_otp(socket.assigns.current_user, user_params) do
      {:ok, user} ->
        info = "Set Authentication App"
        {:noreply, socket |> put_flash(:info, info) |> assign(current_user: user)}

      {:error, changeset} ->
        {:noreply, assign(socket, :otp_form, to_form(Map.put(changeset, :action, :update)))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("reset_otp_secret", _params, socket) do
    user = socket.assigns.current_user

    case Accounts.update_reset_otp(user) do
      {:ok, user} ->
        {:noreply, assign(socket, current_user: user)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
