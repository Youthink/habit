defmodule Habit.Day do
  use Ecto.Schema
  import Ecto.Changeset


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
end
