defmodule Habit.Repo.Migrations.AddUserInfoToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :email, :string
      add :location, :string
      add :github_id, :string
      add :sign_source, :string
    end
  end
end
