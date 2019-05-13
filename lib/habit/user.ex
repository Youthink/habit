defmodule Habit.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Habit.{User, Repo}
  alias Ueberauth.Auth


  schema "users" do
    field :avatar_url, :string
    field :gender, :string
    field :nick, :string
    field :name, :string
    field :email, :string
    field :open_id, :string
    field :union_id, :string
    field :location, :string
    field :github_id, :string
    field :sign_source, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar_url, :nick, :name, :email, :location, :github_id, :sign_source])
    |> validate_required([:nick, :sign_source])
  end

  def create(user) do
    %User{}
    |> changeset(user)
    |> Repo.insert
  end

  def get_user(open_id) do
    query = from user in User,
      where: user.open_id== ^open_id
    query |> Repo.one
  end

  def find_or_create_from_auth(%Auth{provider: :github} = auth) do
    # TODO: Synchronization of user information from a third party
    case find_github_user(auth.uid) do
      user = %User{} ->
        {:ok, user}
      _ -> create_github_user(auth)
    end
  end

  def find_or_create_from_auth(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  defp find_github_user(github_id) do
    query = from user in User,
      where: user.github_id == ^Integer.to_string(github_id)
    query |> Repo.one
  end

  defp create_github_user(auth) do
    user = basic_info(auth)
    a = create(user)
    IO.inspect a
    a
  end

  defp basic_info(auth) do
    %{
      github_id: Integer.to_string(auth.uid),
      name: name_from_auth(auth),
      nick: nick_from_auth(auth),
      email: email_from_auth(auth),
      avatar_url: avatar_from_auth(auth),
      location: location_from_auth(auth),
      sign_source: Atom.to_string(auth.provider)
    }
  end

  defp email_from_auth( %{info: %{email: email} }), do: email

  defp location_from_auth( %{info: %{location: location} }), do: location

  defp name_from_auth( %{info: %{nickname: name} }), do: name

  defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image

  defp avatar_from_auth(_) do
    nil
  end

  defp nick_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end
 end
