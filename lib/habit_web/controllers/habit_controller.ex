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
        fail(conn, %{apiMessage: "无效的 habit id"})

      habit = %Habit{} ->
        data = %{
          id: habit.id,
          name: habit.name,
          score: habit.score
        }

        json(conn, %{success: true, data: data})
    end
  end

  def update(conn, %{
        "code" => code,
        "openId" => open_id,
        "name" => name,
        "score" => score,
        "id" => id
      }) do
    case Habit.update(id, name, score) do
      {:error, :habit_id_invalid} ->
        fail(conn, %{apiMessage: "无效的习惯id，习惯编辑失败", apiCode: 3000})

      {:ok} ->
        success(conn, %{apiMessage: "习惯编辑成功"})

      _ ->
        fail(conn, %{apiMessage: "习惯编辑失败"})
    end
  end

  def create(conn, %{"name" => name, "score" => score}) do
    current_user = get_session(conn, :current_user)

    case Habit.create(current_user, name, score) do
      {:error, :user_info_invalid} ->
        fail(conn, %{apiMessage: "用户身份验证失败", apiCode: 1000})

      {:error, :habit_name_invalid} ->
        fail(conn, %{apiMessage: "无效的习惯名称，习惯创建失败", apiCode: 2001})

      {:error, :habit_score_invalid} ->
        fail(conn, %{apiMessage: "无效的习惯分数，习惯创建失败", apiCode: 2001})

      {:ok, :habit_create_success} ->
        success(conn, %{apiMessage: "习惯创建成功"})
    end
  end

  def create(conn, _) do
    fail(conn, %{apiMessage: "参数有误", apiCode: 2000})
  end

  def complete(conn, %{"habitId" => habit_id}) do
    # TODO: Date of need parameters
    current_user = get_session(conn, :current_user)

    case Habit.check_in(current_user, habit_id) do
      {:error, :check_in_fail} ->
        fail(conn, %{apiMessage: "习惯打卡失败", apiCode: 2002})

      {:ok, :check_in_success} ->
        success(conn, %{apiMessage: "习惯打卡成功"})
    end
  end

  def cancel(conn, %{"habitId" => habit_id}) do
    # TODO: Date of need parameters
    current_user = get_session(conn, :current_user)

    case Habit.cancel(current_user, habit_id) do
      {:error, :cancel_fail} ->
        fail(conn, %{apiMessage: "取消打卡失败", apiCode: 2002})

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
