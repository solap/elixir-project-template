defmodule ExploreWeb.Router do
  use ExploreWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ExploreWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExploreWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/game", GameLive
  end

  if Application.compile_env(:explore, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ExploreWeb.Telemetry
    end
  end
end
