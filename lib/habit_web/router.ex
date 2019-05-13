defmodule HabitWeb.Router do
  use HabitWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  scope "/api/v1", HabitWeb do
    pipe_through(:api)

    scope "/habit" do
      resources("/", HabitController, only: [:index, :create, :update])
      post("/complete", HabitController, :complete)
    end

    get("/day", DayController, :index)

    delete("/logout", AuthController, :delete)

    scope "/auth" do
      get("/:provider", AuthController, :request)
      get("/:provider/callback", AuthController, :callback)
      post("/:provider/callback", AuthController, :callback)
    end
  end
end
