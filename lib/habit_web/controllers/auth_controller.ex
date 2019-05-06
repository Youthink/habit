defmodule HabitWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use HabitWeb, :controller
  alias Habit.User

  plug Ueberauth


  def request(conn, _params) do
  end

  def delete(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{success: true, apiMessage: "You have been logged out!"})
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_status(401)
    |> json(%{success: false, apiMessage: "Failed to authenticate."})
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> json(%{success: true, apiMessage: "Successfully authenticated."})
      {:error, reason} ->
        conn
        |> json(%{success: false, apiMessage: reason})
    end
  end
end
