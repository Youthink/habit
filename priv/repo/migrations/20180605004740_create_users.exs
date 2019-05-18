defmodule Habit.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :nick, :string
      add :email, :string
      add :avatar_url, :string
      add :gender, :string
      add :location, :string
      add :sign_source, :string
      add :github_id, :string
      add :open_id, :string
      add :union_id, :string

      timestamps()
    end
  end
end
