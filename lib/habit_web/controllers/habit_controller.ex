defmodule HabitWeb.HabitController do
  use HabitWeb, :controller
  alias Habit.Habit

  def index(conn, %{"code" => code, "openId" => open_id}) do
    json(conn, %{success: true, apiMessage: "Hello World!"})
  end

  def create(conn, %{"code" => code, "openId" => open_id, "name" => name, "score" => score}) do
    case Habit.create(code, open_id, name, score) do
      {:error, :user_info_invalid}
        -> fail(conn, %{apiMessage: "用户身份验证失败", apiCode: 1000})
      {:error, :wx_code_limit}
        -> fail(conn, %{apiMessage: "微信登录code请求过于频繁", apiCode: 1001})
      {:error, :habit_name_invalid}
        -> fail(conn, %{apiMessage: "无效的习惯民称，习惯创建失败", apiCode: 2001})
      {:ok, :habit_create_success}
        -> success(conn, %{apiMessage: "习惯创建成功"})
    end
  end

  def create(conn, _) do
    fail(conn, %{apiMessage: "参数有误", apiCode: 2000})
  end

  defp success(conn, data) do
    json(conn, Map.merge(data, %{success: true}))
  end

  defp fail(conn, data) do
    json(conn, Map.merge(data, %{success: false}))
  end

end
