defmodule RedEyeWeb.Router do
  use RedEyeWeb, :router

  import RedEyeWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {RedEyeWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :pre_auth_browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {RedEyeWeb.Layouts, :pre_auth})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", RedEyeWeb do
    pipe_through(:browser)

    live("/charts", ChartLive.Index, :index)
    live("/charts/new", ChartLive.New, :new)
    live("/charts/:id/edit", ChartLive.Edit, :edit)

    live("/charts/:id", ChartLive.Show, :show)
    live("/charts/:id/show/edit", ChartLive.Show, :edit)
  end

  # Other scopes may use custom stacks.
  # scope "/api", RedEyeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:red_eye, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: RedEyeWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", RedEyeWeb do
    pipe_through([:pre_auth_browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      layout: {RedEyeWeb.Layouts, :alt_layout},
      on_mount: [{RedEyeWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", RedEyeWeb do
    pipe_through([:browser, :require_authenticated_user])
    get("/", PageController, :home)

    live_session :require_authenticated_user,
      on_mount: [{RedEyeWeb.UserAuth, :ensure_authenticated}] do
      live("/users/opt_code", UserOtpCodeLive, :edit)
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
    end
  end

  scope "/", RedEyeWeb do
    pipe_through([:pre_auth_browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{RedEyeWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
