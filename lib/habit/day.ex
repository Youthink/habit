defmodule Habit.Day do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habit.{Habit, Repo, User, Day}

  @timestamps_opts [
    autogenerate: {EctoTimestamps.Local, :autogenerate, [:sec]}
  ]

  schema "days" do
    field(:status, :string)

    belongs_to(:user, User)
    belongs_to(:habit, Habit)

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
    |> Repo.insert()
  end

  def delete(user, habit_completed_id, habit_id) do
    from(d in Day,
      where:
        d.habit_id == ^habit_id and d.id == ^habit_completed_id and
          d.user_id == ^user.id
    )
    |> Repo.one()
    |> Repo.delete()
  end

  def list(user, date) do
    start_date = Date.from_iso8601!(date)
    end_date = Date.add(start_date, 1)
    finish_habit_id_query = finish_habit_id_query(user, start_date, end_date)

    finish_habit_query =
      from(h in Habit,
        join: f in subquery(finish_habit_id_query),
        where: h.id == f.habit_id,
        select: %{
          id: h.id,
          name: h.name,
          score: h.score,
          date: f.inserted_at,
          status: "finish",
          habitCompletedId: f.id
        }
      )

    finish_list = finish_habit_query |> Repo.all()

    finish_habit_id_query_2 =
      from(d in Day,
        join: u in User,
        where:
          u.id == ^user.id and fragment("?::date", d.inserted_at) >= ^start_date and
            fragment("?::date", d.inserted_at) <= ^end_date,
        select: d.habit_id
      )

    arr = finish_habit_id_query_2 |> Repo.all()

    unfinish_habit_query =
      from(h in Habit,
        where: h.id not in ^arr and h.status != "deleted" and h.user_id == ^user.id,
        distinct: h.id,
        order_by: h.score,
        select: %{id: h.id, name: h.name, score: h.score, status: h.status}
      )

    unfinish_list = unfinish_habit_query |> Repo.all()

    habits_list = unfinish_list ++ finish_list

    total_score = sum_score_finish_habit(user, start_date, end_date)

    week_total_score = sum_score_week_finish_habit(user, start_date)

    %{
      "habitsList" => habits_list,
      "todayTotalScore" => total_score,
      "weekTotalScore" => week_total_score
    }
  end

  defp finish_habit_id_query(user, start_date, end_date) do
    from(d in Day,
      join: u in User,
      where:
        u.id == ^user.id and fragment("?::date", d.inserted_at) >= ^start_date and
          fragment("?::date", d.inserted_at) <= ^end_date
    )
  end

  defp sum_score_finish_habit(user, start_date, end_date) do
    finish_habit_id_query = finish_habit_id_query(user, start_date, end_date)

    finish_habit_query =
      from(h in Habit,
        join: f in subquery(finish_habit_id_query),
        where: h.id == f.habit_id,
        select: sum(h.score)
      )

    finish_habit_query |> Repo.one() || 0
  end

  defp sum_score_week_finish_habit(user, start_date) do
    end_date = Date.add(start_date, 1)
    week_num = Date.day_of_week(start_date)
    monday_date = Date.add(start_date, -(week_num - 1))
    sum_score_finish_habit(user, monday_date, end_date)
  end
end
