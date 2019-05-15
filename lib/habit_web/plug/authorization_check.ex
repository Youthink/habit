defmodule HabitWeb.Plug.Authentication_check do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(_params) do
  end

  def call(conn, _params) do
    current_user = get_session(conn, :current_user)
    # current_user = user_id && Repo.get(User, user_id) ->
    if current_user do
      assign(conn, :current_user, current_user)
    else
      conn
      |> json(%{success: false, apiMessage: "Please login again"})
      |> halt()
    end
  end
end
