defmodule HabitWeb.UserController do
  use HabitWeb, :controller
  import Ecto.Query
  alias Habit.{User, Repo}

  def index(conn, _) do
    current_user = get_session(conn, :current_user)

    case Repo.get(User, current_user.id) do
      user = %User{} ->
        json(
          conn,
          %{
            success: true,
            data: %{
              useId: user.id,
              avatarUrl: user.avatar_url,
              email: user.email,
              name: user.name,
              nick: user.nick
            }
          }
        )

      nil ->
        json(conn, %{success: false, apiCode: "1002", apiMessage: "该用户不存在"})
    end
  end
end
