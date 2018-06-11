defmodule Habit.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nick, :string
      add :open_id, :string
      add :union_id, :string
      add :avatar_url, :string
      add :gender, :string

      timestamps()
    end

    create unique_index(:users, :open_id)
    create unique_index(:users, :union_id)

  end
end
