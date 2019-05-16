defmodule Habit.Habit do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habit.{Habit, Repo, User, Day}

  require Logger

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
    case Repo.get(Habit, id) do
      nil ->
        {:error, :habit_id_invalid}

      habit = %Habit{} ->
        a =
          habit
          |> changeset(%{name: habit.name, score: habit.score})
          |> Repo.update()

        IO.inspect(a)
    end
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

  def check_in(user, habit_id) do
    # TODO: First of all, according to the date and habit_id to query
    case Day.create(user, habit_id) do
      {:ok, day} -> {:ok, :check_in_success}
      _ -> {:error, :check_in_fail}
    end
  end

  def check_in(open_id, habit_id) do
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
