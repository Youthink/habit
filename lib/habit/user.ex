defmodule Habit.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :avatar_url, :string
    field :gender, :string
    field :nick, :string
    field :open_id, :string
    field :union_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:union_id, :open_id, :nick, :avatar_url, :gender])
    |> validate_required([:open_id, :nick, :avatar_url)
  end
end
