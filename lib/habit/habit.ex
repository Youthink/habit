defmodule Habit.Habit do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habit.{Habit, Repo, User}

  require Logger

  schema "habits" do
    field :description, :string
    field :name, :string
    field :score, :integer
    field :status, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:name, :description, :score, :status])
    |> validate_required([:name])
  end

  @wechat_code_to_session_api "https://api.weixin.qq.com/sns/jscode2session"
  #@app_id Application.get_env(:habits, Wechat)[:app_id]
  #@secret Application.get_env(:habits, Wechat)[:secret]

  """
  添加习惯的接口

  正确则继续添加习惯
  不正确则返回 用户身份验证失败 或者 登录太频繁，稍后再试

  习惯的名称、习惯的分数

  添加到数据库

  删除习惯

  修改习惯


  
  """

  def create(code, open_id, name, score) when byte_size(code) > 0 and byte_size(open_id) > 0 and is_binary(code) and is_binary(open_id) do
    if (is_undefined_or_null(code) || is_undefined_or_null(open_id)) do
      {:error, :user_info_invalid}
    else
      #code_valid?(code, open_id)
      #TODO:暂时不验证用户信息
      if (is_undefined_or_null(name)) do
        {:error, :habit_name_invalid}
      else
        user = fetch_user(open_id)
        |> add_habit(name, score)
      end
    end
  end

  def create(code, open_id, name, score) do
    {:error, :user_info_invalid}
  end

  defp add_habit(user, name, score) do
    #TODO: score need to make sure that is digital
    if (is_undefined_or_null(score)) do
      score = 0;
    end
    %Habit{}
    |> changeset(%{
      user_id: user.id,
      name: name,
      score: score
    })
    |> Repo.insert

    {:ok, :habit_create_success}
  end

  defp fetch_user(open_id) do
    case User.get_user(open_id) do
      user = %User{} -> user
      _ ->
        {:ok, newUser} = User.create(open_id)
        newUser
    end
  end

  defp code_valid?(code, open_id) do
    case Mix.env do
      :test ->
        code == "openid:#{open_id}"
      _ ->
        fetch_open_id_from_code(code) == open_id
    end
  end

  defp fetch_open_id_from_code(code) do
    case get_user_info_by_wechat_code(code) do
      open_id when is_binary(open_id) ->
        open_id
      ret ->
        ret
    end
  end

  defp get_user_info_by_wechat_code(code) do
    ret = HTTPoison.get(
      @wechat_code_to_session_api, [],
      params: [
        appid: @app_id,
        secret: @secret,
        js_code: code,
        grant_type: "authorization_code"
      ]
    )

    case ret do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.debug fn -> "code: #{code}; wechat response: #{body}" end
        body
        |> Poison.decode!
        |> Map.get("openid")

      _ ->
        ret
    end
  end

  defp is_undefined_or_null(value) do
    if value === "undefined" || value === "null" do
      true
    else
      false
    end
  end

end
