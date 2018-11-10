defmodule Habit.Day do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habit.{Habit, Repo, User, Day}


  schema "days" do
    field :status, :string

    belongs_to :user, User
    belongs_to :habit, Habit

    timestamps()
  end

  @doc false
  def changeset(day, attrs) do
    day
    |> cast(attrs, [:status, :user_id, :habit_id])
    |> validate_required([:status])
  end

  def create(user, habit_id) do
    %Day{}
    |> changeset(%{
      user_id: user.id,
      habit_id: habit_id,
      status: "complate"
    })
    |> Repo.insert
  end

  def list(open_id, date) do
    date = Date.from_iso8601!(date)
    finish_habit_id_query = from d in Day,
      join: u in User,
      where: u.open_id == ^open_id and fragment("?::date", d.inserted_at) >= ^date

    finish_habit_query = from h in Habit,
      join: f in subquery(finish_habit_id_query),
      where: h.id == f.habit_id,
      select: %{id: h.id, name: h.name, score: h.score, date: f.inserted_at, status: "finish"}
    finish_list  = finish_habit_query |> Repo.all

    finish_habit_id_query_2 = from d in Day,
      join: u in User,
      where: u.open_id == ^open_id and fragment("?::date", d.inserted_at) >= ^date,
      select: d.habit_id

    arr = finish_habit_id_query_2 |> Repo.all

    unfinish_habit_query = from h in Habit,
      where: h.id not in ^arr,
      distinct: h.id,
      order_by: h.score,
      select: %{id: h.id, name: h.name, score: h.score, status: "init"}
    unfinish_list = unfinish_habit_query |> Repo.all

    unfinish_list ++ finish_list

  end
end
