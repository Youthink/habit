defmodule HabitWeb.Router do
  use HabitWeb, :router

  @fe_address Application.get_env(:habit, :fe_address)

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(CORSPlug, origin: @fe_address)
  end

  pipeline :authenticated do
    plug(HabitWeb.Plug.Authentication_check)
  end

  scope "/api/v1", HabitWeb do
    pipe_through(:api)

    scope "/habit" do
      pipe_through(:authenticated)

      resources("/", HabitController, only: [:index, :create, :update, :delete])
      post("/complete", HabitController, :complete)
      post("/cancel", HabitController, :cancel)

      options("/", HabitController, :options)
      options("/:id", HabitController, :options)
    end

    scope "/day" do
      pipe_through(:authenticated)

      resources("/", DayController, only: [:index])
    end

    scope "/user" do
      pipe_through(:authenticated)

      resources("/", UserController, only: [:index])
    end

    delete("/logout", AuthController, :delete)

    scope "/auth" do
      get("/:provider", AuthController, :request)
      get("/:provider/callback", AuthController, :callback)
      post("/:provider/callback", AuthController, :callback)
    end
  end
end
