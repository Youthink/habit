defmodule HabitWeb.HabitController do
  use HabitWeb, :controller
  alias Habit.{Habit, Repo}

  def index(conn, %{}) do
    current_user = get_session(conn, :current_user)
    data = Habit.list(current_user.id)
    json(conn, %{success: true, data: data})
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Habit, id) do
      nil ->
        fail(conn, %{apiMessage: "无效的 habit id", apiCode: 2009})

      habit = %Habit{} ->
        data = %{
          id: habit.id,
          name: habit.name,
          score: habit.score
        }

        json(conn, %{success: true, data: data})
    end
  end

  def update(conn, %{"name" => name, "score" => score, "id" => id}) do
    current_user = get_session(conn, :current_user)

    case Habit.update(id, name, score, current_user.id) do
      {:error, :conditions_not_match} ->
        fail(conn, %{apiMessage: "条件不匹配，习惯编辑失败", apiCode: 2007})

      {:ok, habit} ->
        success(conn, %{apiMessage: "习惯编辑成功", data: habit})

      _ ->
        fail(conn, %{apiMessage: "习惯编辑失败", apiCode: 2008})
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = get_session(conn, :current_user)

    case Habit.delete(id, current_user.id) do
      {:error, :conditions_not_match} ->
        fail(conn, %{apiMessage: "条件不匹配，习惯删除失败", apiCode: 2012})

      {:ok, habit} ->
        success(conn, %{apiMessage: "习惯删除成功"})

      _ ->
        fail(conn, %{apiMessage: "习惯删除失败", apiCode: 2011})
    end
  end

  def create(conn, %{"name" => name, "score" => score}) do
    current_user = get_session(conn, :current_user)

    case Habit.create(current_user, name, score) do
      {:error, :user_info_invalid} ->
        fail(conn, %{apiMessage: "用户身份验证失败", apiCode: 1001})

      {:error, :habit_name_invalid} ->
        fail(conn, %{apiMessage: "无效的习惯名称，习惯创建失败", apiCode: 2001})

      {:error, :habit_score_invalid} ->
        fail(conn, %{apiMessage: "无效的习惯分数，习惯创建失败", apiCode: 2002})

      {:ok, :habit_create_success} ->
        success(conn, %{apiMessage: "习惯创建成功"})
    end
  end

  def create(conn, _) do
    fail(conn, %{apiMessage: "参数有误", apiCode: 2005})
  end

  def complete(conn, %{"habitId" => habit_id, "date" => date}) do
    current_user = get_session(conn, :current_user)

    case Habit.check_in(current_user, date, habit_id) do
      {:error, :check_in_fail} ->
        fail(conn, %{apiMessage: "习惯打卡失败", apiCode: 2003})

      {:error, :completed} ->
        fail(conn, %{apiMessage: "该习惯已经打卡，不能重复打卡", apiCode: 2004})

      {:ok, :check_in_success} ->
        success(conn, %{apiMessage: "习惯打卡成功"})
    end
  end

  def complete(conn, _) do
    fail(conn, %{apiMessage: "参数有误", apiCode: 2010})
  end

  def cancel(conn, %{"habitId" => habit_id, "habitCompletedId" => habit_completed_id}) do
    current_user = get_session(conn, :current_user)

    case Habit.cancel(current_user, habit_completed_id, habit_id) do
      {:error, :cancel_fail} ->
        fail(conn, %{apiMessage: "取消打卡失败", apiCode: 2006})

      {:ok, :cancel_success} ->
        success(conn, %{apiMessage: "取消打卡打卡成功"})
    end
  end

  defp success(conn, data) do
    json(conn, Map.merge(data, %{success: true}))
  end

  defp fail(conn, data) do
    json(conn, Map.merge(data, %{success: false}))
  end
end
