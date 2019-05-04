defmodule HabitWeb.Router do
  use HabitWeb, :router

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

  scope "/", HabitWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end


  scope "/api", HabitWeb do
    pipe_through :api

    resources "/habit", HabitController
    post "/checkIn", HabitController, :check_in
    get "/day", DayController, :index
    get "/decrypt", ToolController, :decrypt
  end

  scope "/auth", HabitWeb do
    pipe_through [:browser]

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    post "/logout", AuthController, :delete
  end


  # Other scopes may use custom stacks.
  # scope "/api", HabitWeb do
  #   pipe_through :api
  # end
end
