defmodule HabitWeb.DayController do
  use HabitWeb, :controller
  alias Habit.Day

  def index(conn, %{"code" => code, "openId" => open_id, "date" => date}) do
    data = Day.list(open_id, date)
    json(conn, %{success: true, data: data})
  end

  def index(conn, _) do
    json(conn, %{success: false})
  end


  defp success(conn, data) do
    json(conn, Map.merge(data, %{success: true}))
  end

  defp fail(conn, data) do
    json(conn, Map.merge(data, %{success: false}))
  end

end
