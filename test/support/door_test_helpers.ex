defmodule DoormanWeb.DoorTestHelpers do
  use Phoenix.ConnTest

  alias Doorman.Access
  alias Doorman.Accounts

  @create_door_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "User Door"}
  @create_other_door_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "Other Door"}

  def add_door(%{user: user}) do
    {:ok, door} = Access.create_user_door(user, @create_door_attrs)
    {:ok, %{door: door}}
  end

  def add_other_door(%{other_user: user}) do
    {:ok, door} = Access.create_user_door(user, @create_other_door_attrs)
    {:ok, %{other_door: door}}
  end

  def add_open_grant(%{door: door}) do
    {:ok, grant} = Access.create_grant(%{timeout: one_hour_from_now(), door_id: door.id})
    {:ok, %{open_grant: grant}}
  end

  def add_closed_grant(%{door: door}) do
    {:ok, grant} = Access.create_grant(%{timeout: now(), door_id: door.id})
    {:ok, %{closed_grant: grant}}
  end

  def add_other_grant(%{other_door: other_door}) do
    {:ok, grant} = Access.create_grant(%{timeout: ~U[2011-05-18 15:01:01Z], door_id: other_door.id})
    {:ok, %{other_grant: grant}}
  end

  def user_fixture do
    {:ok, user} = Accounts.create_user(%{email: "asdf@example.com", password: "asdfasdf"})
    user
  end

  def door_fixture(attrs \\ %{}) do
    {:ok, door} = Access.create_user_door(
      user_fixture(),
      attrs |> Enum.into(%{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "some name"})
    )

    door
  end

  def grant_fixture(:open, door) do
    {:ok, grant} = Access.create_grant(%{timeout: one_hour_from_now(), door_id: door.id})
    grant
  end

  def grant_fixture(:closed, door) do
    {:ok, grant} = Access.create_grant(%{timeout: now(), door_id: door.id})
    grant
  end

  defp now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end

  defp one_hour_from_now do
    DateTime.utc_now()
    |> DateTime.add(3600, :second)
    |> DateTime.truncate(:second)
  end

end
