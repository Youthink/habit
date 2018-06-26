defmodule Habit.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habit.{User, Repo}


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
    |> validate_required([:open_id])
    #|> validate_required([:open_id, :nick, :avatar_url])
  end

  def create(open_id) do
    %User{}
    |> changeset(%{open_id: open_id})
    |> Repo.insert
  end

  def get_user(open_id) do
    query = from user in User,
      where: user.open_id== ^open_id
    query |> Repo.one
  end

end
