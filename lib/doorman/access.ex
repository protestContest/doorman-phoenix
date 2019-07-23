defmodule Doorman.Access do
  import Ecto.Query, warn: false
  alias Doorman.Repo

  alias Doorman.Access.Door
  alias Doorman.Accounts.User
  alias Doorman.Access.Grant

  def list_doors do
    Repo.all(Door)
    |> Repo.preload(:user)
  end

  def list_doors(%User{} = user) do
    Repo.all(
      from d in Door,
      join: u in User,
      where:
        d.user_id == u.id and
        u.id == ^user.id,
      preload: [:user]
    )
  end

  def get_door!(id), do: Repo.get!(Door, id) |> Repo.preload(:user)

  def create_user_door(user, attrs) do
    %Door{user: user}
    |> Door.changeset(attrs)
    |> Repo.insert()
  end

  def update_door(%Door{} = door, attrs) do
    door
    |> Door.changeset(attrs)
    |> Repo.update()
  end

  def delete_door(%Door{} = door) do
    Repo.delete(door)
  end

  def change_door(%Door{} = door) do
    Door.changeset(door, %{})
  end

  def load_for_user(%User{} = user) do
    Repo.preload(user, :doors)
  end

  alias Doorman.Access.Grant

  def list_grants do
    Repo.all(Grant)
  end

  def list_grants(%User{} = user) do
    Repo.all(
      from g in Grant,
      join: d in Door,
      join: u in User,
      where:
        g.door_id == d.id and
        d.user_id == u.id and
        u.id == ^user.id
    )
  end

  def get_grant!(id), do: Repo.get!(Grant, id)

  def create_grant(attrs \\ %{}) do
    %Grant{}
    |> Grant.create_changeset(attrs)
    |> Repo.insert()
  end

  def update_grant(%Grant{} = grant, attrs) do
    grant
    |> Grant.changeset(attrs)
    |> Repo.update()
  end

  def delete_grant(%Grant{} = grant) do
    Repo.delete(grant)
  end

  def change_grant(%Grant{} = grant) do
    Grant.changeset(grant, %{})
  end
end
