defmodule FunnyWeb.Router do
  use FunnyWeb, :router

  # Our pipeline implements "maybe" authenticated. We'll use the `:ensure_auth` below for when we need to make sure someone is logged in.
  pipeline :auth do
    plug Funny.Accounts.Pipeline
  end

  # We use ensure_auth to fail if there is no one logged in
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FunnyWeb do
    pipe_through [:browser, :auth]

    get "/funny-service", PageController, :test
    get "/", PageController, :index
  end

  scope "/", FunnyWeb do
    pipe_through [:api, :auth]

    post "/login", AuthController, :login
    get "/logout", AuthController, :logout
  end

  scope "/api", FunnyWeb do
    pipe_through [:api, :auth, :ensure_auth]

    resources "/persons", PersonController, only: [:index]
    resources "/jokes", JokeController, except: [:update]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: FunnyWeb.Telemetry
    end
  end
end
