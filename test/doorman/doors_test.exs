defmodule Doorman.DoorsTest do
  use Doorman.DataCase

  alias Doorman.Doors

  describe "doors" do
    alias Doorman.Doors.Door
    alias Doorman.Accounts

    @user_attrs %{email: "asdf@example.com", password: "asdfasdf"}
    @valid_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "some name"}
    @update_attrs %{forward_number: "some updated forward_number", incoming_number: "some updated incoming_number", name: "some updated name"}
    @invalid_attrs %{forward_number: nil, incoming_number: nil, name: nil}

    def user_fixture do
      {:ok, user} = Accounts.create_user(@user_attrs)
      user
    end

    def door_fixture(attrs \\ %{}) do
      {:ok, door} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Doors.create_door(user_fixture())

      door
    end

    test "list_doors/0 returns all doors" do
      door = door_fixture()
      assert Doors.list_doors() == [door]
    end

    test "get_door!/1 returns the door with given id" do
      door = door_fixture()
      assert Doors.get_door!(door.id) == door
    end

    test "create_door/1 with valid data creates a door" do
      user = user_fixture()
      assert {:ok, %Door{} = door} = Doors.create_door(@valid_attrs, user)
      assert door.forward_number == "some forward_number"
      assert door.incoming_number == "some incoming_number"
      assert door.name == "some name"
    end

    test "create_door/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Doors.create_door(@invalid_attrs, user)
    end

    test "update_door/2 with valid data updates the door" do
      door = door_fixture()
      assert {:ok, %Door{} = door} = Doors.update_door(door, @update_attrs)
      assert door.forward_number == "some updated forward_number"
      assert door.incoming_number == "some updated incoming_number"
      assert door.name == "some updated name"
    end

    test "update_door/2 with invalid data returns error changeset" do
      door = door_fixture()
      assert {:error, %Ecto.Changeset{}} = Doors.update_door(door, @invalid_attrs)
      assert door == Doors.get_door!(door.id)
    end

    test "delete_door/1 deletes the door" do
      door = door_fixture()
      assert {:ok, %Door{}} = Doors.delete_door(door)
      assert_raise Ecto.NoResultsError, fn -> Doors.get_door!(door.id) end
    end

    test "change_door/1 returns a door changeset" do
      door = door_fixture()
      assert %Ecto.Changeset{} = Doors.change_door(door)
    end
  end

  describe "grants" do
    alias Doorman.Doors.Grant

    @valid_attrs %{timeout: ~N[2010-04-17 14:00:00]}
    @invalid_attrs %{timeout: nil}

    def grant_fixture(attrs \\ %{}) do
      {:ok, grant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Doors.create_grant(door_fixture())

      grant
    end

    test "list_grants/0 returns all grants" do
      grant = grant_fixture()
      assert Doors.list_grants() == [grant]
    end

    test "get_grant!/1 returns the grant with given id" do
      grant = grant_fixture()
      assert Doors.get_grant!(grant.id) == grant
    end

    test "create_grant/1 with valid data creates a grant" do
      door = door_fixture()
      assert {:ok, %Grant{} = grant} = Doors.create_grant(@valid_attrs, door)
      assert grant.timeout == ~U[2010-04-17 14:00:00Z]
    end

    test "create_grant/1 with invalid data returns error changeset" do
      door = door_fixture()
      assert {:error, %Ecto.Changeset{}} = Doors.create_grant(@invalid_attrs, door)
    end

    test "change_grant/1 returns a grant changeset" do
      grant = grant_fixture()
      assert %Ecto.Changeset{} = Doors.change_grant(grant)
    end
  end
end
