defmodule Doorman.Access do
  import Ecto.Query, warn: false
  alias Doorman.Repo

  alias Doorman.Access.Door
  alias Doorman.Accounts.User
  alias Doorman.Access.Grant
  alias Doorman.Twilio

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
    attrs = Map.delete(attrs, "user_id")
    %Door{user: user}
    |> Door.changeset(attrs)
    |> create_twilio_number(attrs)
    |> Repo.insert()
  end

  def create_twilio_number(changeset, attrs) do
    number = Twilio.create_number(attrs["name"])
    changeset
    |> Ecto.Changeset.put_change(:incoming_number, number["phone_number"])
    |> Ecto.Changeset.put_change(:incoming_number_sid, number["sid"])
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
    |> Grant.changeset(attrs)
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

  def change_door_grant(%Door{} = door, %Grant{} = grant) do
    Grant.changeset(grant, %{door_id: door.id, timeout: default_grant_timeout()})
  end

  def door_status(%Door{} = door) do
    if grant_expired?(last_grant(door)), do: :closed, else: :open
  end

  def grant_expired?(%Grant{} = grant) do
    if DateTime.compare(DateTime.utc_now(), grant.timeout) == :lt do
      false
    else
      true
    end
  end

  def grant_expired?(nil), do: true

  def last_grant(%Door{} = door) do
    grant = (
      from g in Grant,
      join: d in Door,
      where: g.door_id == ^door.id,
      order_by: [desc: :inserted_at, desc: :id]
    )
    |> limit(1)
    |> Repo.one

    grant
  end

  def open_door(%Door{} = door, seconds) do
    timeout = DateTime.add(DateTime.utc_now(), seconds)
    {:ok, grant} = create_grant(%{timeout: timeout, door_id: door.id})
    grant
  end

  def close_door(%Door{} = door), do: open_door(door, 0)

  def recent_grants(%Door{} = door) do
    day_ago = DateTime.add(DateTime.utc_now(), -24*3600)

    grants = (
      from g in Grant,
      where: g.door_id == ^door.id
        and g.inserted_at > ^day_ago,
      order_by: [desc: :inserted_at, desc: :id]
    )
    |> Repo.all
    |> Repo.preload(:door)

    grants
  end

  def grant_duration(%Grant{} = grant) do
    DateTime.diff(grant.timeout, grant.inserted_at)
  end

  def grant_type(%Grant{} = grant) do
    if grant_duration(grant) == 0, do: :closed, else: :open
  end

  def get_door_by_number!(incoming_number) do
    Repo.one!(from d in Door, where: d.incoming_number == ^incoming_number)
  end

  defp default_grant_timeout do
    half_hour_seconds = 1800
    DateTime.add(DateTime.utc_now(), half_hour_seconds)
  end
end

