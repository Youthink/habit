defmodule Habit.Repo.Migrations.DropWxUniqueIndexToUser do
  use Ecto.Migration

  def change do
    drop index("users", :open_id)
    drop index("users", :union_id)
  end
end
