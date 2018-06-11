defmodule Habit.Repo.Migrations.CreateDays do
  use Ecto.Migration

  def change do
    create table(:days) do
      add :habit_id, references(:habits, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :status, :string

      timestamps()
    end

    create index(:days, [:user_id, :habit_id])

  end
end
