defmodule DoormanWeb.DoorTestHelpers do
  use Phoenix.ConnTest

  alias Doorman.Doors

  @create_door_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "User Door"}
  @create_other_door_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "Other Door"}

  def add_door(%{user: user}) do
    {:ok, door} = Doors.create_door(@create_door_attrs, user)
    {:ok, %{door: door}}
  end

  def add_other_door(%{other_user: user}) do
    {:ok, door} = Doors.create_door(@create_other_door_attrs, user)
    {:ok, %{other_door: door}}
  end

  def add_open_grant(%{door: door}) do
    {:ok, grant} = Doors.add_door_grant(door, %{timeout: one_hour_from_now()})
    {:ok, %{grant: grant}}
  end

  def add_closed_grant(%{door: door}) do
    {:ok, grant} = Doors.add_door_grant(door, %{timeout: now()})
    {:ok, %{grant: grant}}
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
