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
  end

  scope "/api", HabitWeb do
    pipe_through :api

    resources "/habit", HabitController,  only: [:index, :create, :update]
    post "/checkIn", HabitController, :check_in
    get "/day", DayController, :index
  end


  # Other scopes may use custom stacks.
  # scope "/api", HabitWeb do
  #   pipe_through :api
  # end
end
