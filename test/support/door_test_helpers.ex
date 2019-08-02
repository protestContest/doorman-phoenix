defmodule DoormanWeb.DoorTestHelpers do
  use Phoenix.ConnTest

  alias Doorman.Access
  alias Doorman.Accounts

  def door_attrs do
    %{forward_number: "some forward_number", name: "User Door", timezone: "Etc/UTC"}
  end

  def door_attrs(:invalid) do
    %{forward_number: nil, incoming_number: nil, name: nil}
  end

  def other_door_attrs do
    %{forward_number: "some forward_number", name: "Other Door", timezone: "Etc/UTC"}
  end

  def grant_attrs(:open, door) do
    %{timeout: one_hour_from_now(), door_id: door.id}
  end

  def grant_attrs(:closed, door) do
    %{timeout: now(), door_id: door.id}
  end

  def user_fixture do
    {:ok, user} = Accounts.create_user(%{email: "asdf@example.com", password: "asdfasdf"})
    user
  end

  def door_fixture(), do: door_fixture(user_fixture())
  def door_fixture(%Accounts.User{} = user, %{} = attrs \\ door_attrs()) do
    {:ok, door} = Access.create_user_door(user, attrs)
    door
  end

  def grant_fixture(:open, door), do: grant_fixture(3600, door)

  def grant_fixture(:closed, door), do: grant_fixture(0, door)

  def grant_fixture(seconds, door) do
    timeout = DateTime.utc_now()
    |> DateTime.add(seconds, :second)
    |> DateTime.truncate(:second)

    {:ok, grant} = Access.create_grant(%{timeout: timeout, door_id: door.id})
    grant
  end

  def add_door(%{user: user}) do
    {:ok, %{door: door_fixture(user)}}
  end

  def add_other_door(%{other_user: user}) do
    door = door_fixture(user, other_door_attrs())
    {:ok, %{other_door: door}}
  end

  def add_open_grant(%{door: door}) do
    {:ok, %{open_grant: grant_fixture(:open, door)}}
  end

  def add_closed_grant(%{door: door}) do
    {:ok, %{closed_grant: grant_fixture(:closed, door)}}
  end

  def add_other_grant(%{other_door: other_door}) do
    {:ok, %{other_grant: grant_fixture(1337, other_door)}}
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
