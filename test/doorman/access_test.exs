defmodule Doorman.AccessTest do
  use Doorman.DataCase

  alias Doorman.Access
  import DoormanWeb.DoorTestHelpers

  describe "doors" do
    alias Doorman.Access.Door

    @valid_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "some name"}
    @update_attrs %{forward_number: "some updated forward_number", incoming_number: "some updated incoming_number", name: "some updated name"}
    @invalid_attrs %{forward_number: nil, incoming_number: nil, name: nil}

    test "list_doors/0 returns all doors" do
      door = door_fixture()
      assert Access.list_doors() == [door]
    end

    test "get_door!/1 returns the door with given id" do
      door = door_fixture()
      assert Access.get_door!(door.id) == door
    end

    test "create_user_door/2 with valid data creates a door" do
      user = user_fixture()
      assert {:ok, %Door{} = door} = Access.create_user_door(user, @valid_attrs)
      assert door.forward_number == "some forward_number"
      assert door.incoming_number == "some incoming_number"
      assert door.name == "some name"
    end

    test "create_user_door/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Access.create_user_door(user, @invalid_attrs)
    end

    test "update_door/2 with valid data updates the door" do
      door = door_fixture()
      assert {:ok, %Door{} = door} = Access.update_door(door, @update_attrs)
      assert door.forward_number == "some updated forward_number"
      assert door.incoming_number == "some updated incoming_number"
      assert door.name == "some updated name"
    end

    test "update_door/2 with invalid data returns error changeset" do
      door = door_fixture()
      assert {:error, %Ecto.Changeset{}} = Access.update_door(door, @invalid_attrs)
      assert door == Access.get_door!(door.id)
    end

    test "delete_door/1 deletes the door" do
      door = door_fixture()
      assert {:ok, %Door{}} = Access.delete_door(door)
      assert_raise Ecto.NoResultsError, fn -> Access.get_door!(door.id) end
    end

    test "change_door/1 returns a door changeset" do
      door = door_fixture()
      assert %Ecto.Changeset{} = Access.change_door(door)
    end
  end

  describe "grants" do
    alias Doorman.Access.Grant

    @valid_attrs %{timeout: ~N[2010-04-17 14:00:00]}
    @invalid_attrs %{timeout: nil}

    test "list_grants/0 returns all grants" do
      grant = grant_fixture(:open, door_fixture())
      assert Access.list_grants() == [grant]
    end

    test "get_grant!/1 returns the grant with given id" do
      grant = grant_fixture(:open, door_fixture())
      assert Access.get_grant!(grant.id) == grant
    end

    test "create_grant/1 with valid data creates a grant" do
      door = door_fixture()
      attrs = Enum.into(@valid_attrs, %{door_id: door.id})
      assert {:ok, %Grant{} = grant} = Access.create_grant(attrs)
      assert grant.timeout == ~U[2010-04-17 14:00:00Z]
    end

    test "create_grant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Access.create_grant(@invalid_attrs)
    end

    test "change_grant/1 returns a grant changeset" do
      grant = grant_fixture(:open, door_fixture())
      assert %Ecto.Changeset{} = Access.change_grant(grant)
    end

    test "grant_expired?/1 returns true if timestamp is older than now" do
      grant = grant_fixture(:closed, door_fixture())
      assert Access.grant_expired?(grant)
    end

    test "grant_expired?/1 returns false if timestamp is in the future" do
      grant = grant_fixture(:open, door_fixture())
      refute Access.grant_expired?(grant)
    end

    test "last_grant/1 returns the last inserted grant for a door" do
      door = door_fixture()
      old_grant = grant_fixture(:open, door)
      new_grant = grant_fixture(:open, door)
      assert old_grant != Access.last_grant(door)
      assert new_grant == Access.last_grant(door)
    end
  end

  describe "status" do
    test "door_status/1 returns :open if last grant is valid" do
      door = door_fixture()
      _grant = grant_fixture(:closed, door)
      _grant = grant_fixture(:open, door)
      assert :open = Access.door_status(door)
    end

    test "door_status/1 returns :closed if last grant is expired" do
      door = door_fixture()
      _grant = grant_fixture(:open, door)
      _grant = grant_fixture(:closed, door)
      assert :closed = Access.door_status(door)
    end

    test "door_status/1 returns :closed if no grants exist" do
      door = door_fixture()
      assert :closed = Access.door_status(door)
    end
  end

  describe "control" do
    test "open_door/2 creates a new grant with a future timeout" do
      door = door_fixture()
      grant = Access.open_door(door, 3600)
      refute is_nil(grant)
      assert grant == Access.last_grant(door)
      refute Access.grant_expired?(grant)
    end

    test "close_door/1 creates a new grant with an expired timeout" do
      door = door_fixture()
      grant = Access.close_door(door)
      refute is_nil(grant)
      assert grant == Access.last_grant(door)
      assert Access.grant_expired?(grant)
    end
  end

end
