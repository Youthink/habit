defmodule Habit.Day do
  use Ecto.Schema
  import Ecto.Changeset
  alias Habit.{Habit, Repo, User, Day}


  schema "days" do
    field :status, :string
    field :user_id, :id
    field :habit_id, :id

    timestamps()
  end

  @doc false
  def changeset(day, attrs) do
    day
    |> cast(attrs, [:status])
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
end
