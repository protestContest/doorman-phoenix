defmodule Doorman.AccessTest do
  use Doorman.DataCase

  alias Doorman.Access
  import DoormanWeb.DoorTestHelpers

  describe "doors" do
    alias Doorman.Access.Door

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
      attrs = door_attrs()
      assert {:ok, %Door{} = door} = Access.create_user_door(user, attrs)
      assert door.forward_number == attrs.forward_number
      assert door.name == attrs.name
    end

    test "create_user_door/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Access.create_user_door(user, door_attrs(:invalid))
    end

    test "update_door/2 with valid data updates the door" do
      door = door_fixture()
      update_attrs = %{forward_number: "new number", name: "new name"}
      assert {:ok, %Door{} = door} = Access.update_door(door, update_attrs)
      assert door.forward_number == "new number"
      assert door.name == "new name"
    end

    test "update_door/2 with invalid data returns error changeset" do
      door = door_fixture()
      assert {:error, %Ecto.Changeset{}} = Access.update_door(door, door_attrs(:invalid))
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

    test "list_grants/0 returns all grants" do
      grant = grant_fixture(:open, door_fixture())
      assert Access.list_grants() == [grant]
    end

    test "get_grant!/1 returns the grant with given id" do
      grant = grant_fixture(:open, door_fixture())
      assert Access.get_grant!(grant.id) == grant
    end

    test "create_grant/1 with valid data creates a grant" do
      attrs = grant_attrs(:open, door_fixture())
      assert {:ok, %Grant{} = grant} = Access.create_grant(attrs)
      assert grant.timeout == attrs.timeout
    end

    test "create_grant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Access.create_grant(%{timeout: nil})
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

    test "recent_grants/1 returns the last grants for a door in reverse chrono order" do
      user = user_fixture()
      door = door_fixture(user)
      other_door = door_fixture(user)
      old_grant = grant_fixture(:open, door)
      new_grant = grant_fixture(:open, door)
      other_grant = grant_fixture(:open, other_door)

      grant_list = Access.recent_grants(door)

      assert length(grant_list) == 2
      refute is_nil(Enum.find(grant_list, nil, fn g -> g.id == old_grant.id end))
      refute is_nil(Enum.find(grant_list, nil, fn g -> g.id == new_grant.id end))
      assert is_nil(Enum.find(grant_list, nil, fn g -> g.id == other_grant.id end))

      old_index = Enum.find_index(grant_list, fn g -> g.id == old_grant.id end)
      new_index = Enum.find_index(grant_list, fn g -> g.id == new_grant.id end)
      assert new_index < old_index
    end

    test "grant_duration/1 returns the number of seconds for a grant" do
      grant = grant_fixture(1800, door_fixture())
      assert 1800 == Access.grant_duration(grant)
    end

    test "grant_type/1 returns whether a grant was to open or close a door" do
      door = door_fixture()
      close_grant = grant_fixture(:closed, door)
      open_grant = grant_fixture(:open, door)
      assert :closed == Access.grant_type(close_grant)
      assert :open == Access.grant_type(open_grant)
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
