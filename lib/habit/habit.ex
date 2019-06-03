defmodule Habit.Habit do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habit.{Habit, Repo, User, Day}

  require Logger

  @timestamps_opts [
    autogenerate: {EctoTimestamps.Local, :autogenerate, [:sec]}
  ]

  schema "habits" do
    field(:description, :string)
    field(:name, :string)
    field(:score, :integer)
    field(:status, :string, default: "init")

    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:user_id, :name, :description, :score, :status])
    |> validate_required([:name])
  end

  def create(user, name, score) do
    if is_undefined_or_null(name) do
      {:error, :habit_name_invalid}
    else
      add_habit(user, name, score)
    end
  end

  def update(id, name, score) do
    case Repo.get!(Habit, id) do
      nil ->
        {:error, :habit_id_invalid}

      habit = %Habit{} ->
        habit
        |> changeset(%{name: name, score: score})
        |> Repo.update!()
        |> return_update_habit_info()
    end
  end

  defp return_update_habit_info(habit = %Habit{}) do
    {:ok, %{name: habit.name, id: habit.id, score: habit.score}}
  end

  defp return_update_habit_info() do
    {:error}
  end

  defp add_habit(user, name, score) do
    if is_undefined_or_null(score) do
      score = 0
    end

    %Habit{}
    |> changeset(%{
      user_id: user.id,
      name: name,
      score: String.to_integer(score)
    })
    |> Repo.insert()

    {:ok, :habit_create_success}
  end

  def list(user_id) do
    query =
      from(h in Habit,
        join: u in User,
        where: u.id == ^user_id and u.id == h.user_id,
        select: %{id: h.id, name: h.name, score: h.score, status: h.status}
      )

    query |> Repo.all()
  end

  def check_in(user, date, habit_id) do
    if check_date_habit_status(user, date, habit_id) do
      {:error, :completed}
    else
      case Day.create(user, habit_id) do
        {:ok, day} -> {:ok, :check_in_success}
        _ -> {:error, :check_in_fail}
      end
    end
  end

  defp check_date_habit_status(user, date, habit_id) do
    start_date = Date.from_iso8601!(date)
    end_date = Date.add(start_date, 1)

    result =
      from(d in Day,
        join: u in User,
        where:
          d.user_id == ^user.id and d.habit_id == ^habit_id and
            fragment("?::date", d.inserted_at) >= ^start_date and
            fragment("?::date", d.inserted_at) <= ^end_date
      )
      |> Repo.exists?()
  end

  def check_in(user, date, habit_id) do
    {:error, :check_in_fail}
  end

  def cancel(user, habit_id) do
    # TODO: First of all, according to the date and habit_id to query
    case Day.delete(user, habit_id) do
      {:ok, day} -> {:ok, :cancel_success}
      _ -> {:error, :cancel_fail}
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
