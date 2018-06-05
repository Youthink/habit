defmodule HabitWeb.PageController do
  use HabitWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
