defmodule HabitWeb.DayController do
  use HabitWeb, :controller
  alias Habit.Day

  def index(conn, %{"date" => date}) do
    current_user = get_session(conn, :current_user)
    data = Day.list(current_user, date)
    json(conn, %{success: true, data: data})
  end

  def index(conn, _) do
    json(conn, %{success: false, apiCode: "2000", apiMessage: "缺少日期参数 date"})
  end

  defp success(conn, data) do
    json(conn, Map.merge(data, %{success: true}))
  end

  defp fail(conn, data) do
    json(conn, Map.merge(data, %{success: false}))
  end
end
