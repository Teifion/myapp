defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  import MyAppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MyAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :maybe_auth do
    plug MyAppWeb.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyAppWeb.General do
    pipe_through [:browser]

    live_session :general_index,
      on_mount: [
        {MyAppWeb.UserAuth, :mount_current_user}
      ] do
      live "/", HomeLive.Index, :index
      live "/guest", HomeLive.Guest, :index
    end
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :maybe_auth]

    get "/readme", PageController, :readme
  end

  scope "/admin", MyAppWeb.Admin do
    pipe_through [:browser]

    live_session :admin_index,
      on_mount: [
        {MyAppWeb.UserAuth, :ensure_authenticated},
        {MyAppWeb.UserAuth, {:authorise, "admin"}}
      ] do
      live "/", HomeLive, :index
    end
  end

  scope "/admin/accounts", MyAppWeb.Admin.Account do
    pipe_through [:browser]

    live_session :admin_accounts,
      on_mount: [
        {MyAppWeb.UserAuth, :ensure_authenticated},
        {MyAppWeb.UserAuth, {:authorise, ~w(admin)}}
      ] do
      live "/", IndexLive
      live "/user/new", NewLive
      live "/user/edit/:user_id", ShowLive, :edit
      live "/user/:user_id", ShowLive
    end
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MyAppWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/login", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    get "/login/:code", UserSessionController, :login_from_code
    post "/login", UserSessionController, :create
  end

  scope "/", MyAppWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete
    post "/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{MyAppWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/admin", MyAppWeb.Admin do
    pipe_through [:browser]
    import Phoenix.LiveDashboard.Router

    live_dashboard("/live_dashboard",
      metrics: MyApp.TelemetrySupervisor,
      ecto_repos: [MyApp.Repo],
      on_mount: [
        {MyAppWeb.UserAuth, :ensure_authenticated},
        {MyAppWeb.UserAuth, {:authorise, "admin"}}
      ],
      additional_pages: [
        # live_dashboard_additional_pages
      ]
    )
  end
end
