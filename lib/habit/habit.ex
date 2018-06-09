defmodule Habit.Habit do
  use Ecto.Schema
  import Ecto.Changeset


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
    |> validate_required([:name, :status])
  end
end
