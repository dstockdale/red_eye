defmodule RedEyeWeb.UserLoginLive do
  use RedEyeWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="max-w-sm p-8 mx-auto mt-10">
      <.h1 class="text-2xl text-center">
        Sign in to account
      </.h1>

      <.p class="text-center">
        Don't have an account?
      </.p>
      <.p class="text-center">
        <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
          Sign up
        </.link>
        for an account now.
      </.p>

      <.form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.field field={@form[:email]} type="email" label="Email" required />
        <.field field={@form[:password]} type="password" label="Password" required />

        <.field field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
        <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
          Forgot your password?
        </.link>

        <div class="flex justify-end">
          <.button phx-disable-with="Signing in...">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
