defmodule HabitWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use HabitWeb, :controller
  alias Habit.User

  plug(Ueberauth)

  def request(conn, _params) do
  end

  def delete(conn, _params) do
    conn
    |> put_status(200)
    |> configure_session(drop: true)
    |> json(%{success: true, apiMessage: "You have been logged out!"})
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_status(401)
    |> json(%{success: false, apiCode: '', apiMessage: "failed to authenticate."})
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case User.find_or_create_from_auth(auth) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "http://fe.iday.top:8000/habit")
        |> halt()
        """
        |> json(%{
          success: true,
          data: %{
            avatarUrl: user.avatar_url,
            nick: user.nick
          },
          apiMessage: "Successfully authenticated."
        })
        """

      {:error, reason} ->
        conn
        |> json(%{success: false, apiMessage: reason})
    end
  end
end
