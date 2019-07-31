defmodule DoormanWeb.DoorControllerTest do
  use DoormanWeb.ConnCase

  import DoormanWeb.AuthTestHelpers
  import DoormanWeb.DoorTestHelpers

  alias Doorman.Access

  @create_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "User Door", timezone: "Etc/UTC"}
  @update_attrs %{forward_number: "some updated forward_number", incoming_number: "some updated incoming_number", name: "some updated name"}
  @invalid_attrs %{forward_number: nil, incoming_number: nil, name: nil}

  setup %{conn: conn} do
    conn = conn |> bypass_through(DoormanWeb.Router, [:browser]) |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "guests" do
    setup [:add_other_user, :add_other_door]

    test "cannot list a user's doors", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :index))
      assert redirected_to_login(conn)
    end

    test "cannot see a form to create a new door", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :new))
      assert redirected_to_login(conn)
    end

    test "cannot create a user's door", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @create_attrs)
      assert redirected_to_login(conn)
    end

    test "cannot show a user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert redirected_to_login(conn)
    end

    test "cannot see a form to edit a door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert redirected_to_login(conn)
    end

    test "cannot update a user's door", %{conn: conn, other_door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert redirected_to_login(conn)
    end

    test "cannot delete a door", %{conn: conn, other_door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert redirected_to_login(conn)
    end

    test "cannot open a door", %{conn: conn, other_door: door} do
      conn = post(conn, Routes.door_path(conn, :open, door))
      assert redirected_to_login(conn)
    end

    test "cannot close a door", %{conn: conn, other_door: door} do
      conn = post(conn, Routes.door_path(conn, :close, door))
      assert redirected_to_login(conn)
    end
  end

  describe "normal users" do
    setup [:add_user_session, :add_door, :add_other_user, :add_other_door]

    test "cannot list another user's doors", %{conn: conn, user: user, other_door: other_door} do
      extra_door = door_fixture(user)
      conn = get(conn, Routes.door_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ extra_door.name
      refute response =~ other_door.name
    end

    test "can list their own doors", %{conn: conn, user: user, door: door} do
      extra_door = door_fixture(user)
      conn = get(conn, Routes.door_path(conn, :index))
      assert html_response(conn, 200) =~ door.name
      assert html_response(conn, 200) =~ extra_door.name
    end

    test "are redirected to the door detail page if only one door exists", %{conn: conn, door: door} do
      conn = get(conn, Routes.door_path(conn, :index))
      assert redirected_to(conn) == Routes.door_path(conn, :show, door)
    end

    test "can see a form to create their own door", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :new))
      assert html_response(conn, 200) =~ "New Door"
    end

    test "cannot create another user's door", %{conn: conn, other_user: other_user} do
      create_attrs = Map.put(@create_attrs, :user_id, other_user.id)
      conn = post(conn, Routes.door_path(conn, :create), door: create_attrs)
      assert %{id: id} = redirected_params(conn)
      new_door = Access.get_door!(id)
      refute new_door.user_id == other_user.id
    end

    test "can create their own door", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.door_path(conn, :show, id)
    end

    test "sees form errors when creating a door with invalid data", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @invalid_attrs)
      assert html_response(conn, 200) =~ "Oops"
    end

    test "cannot show another user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    test "can show their own door", %{conn: conn, door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert html_response(conn, 200)
    end

    test "cannot see a form to edit another user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    test "can see a form to edit their own door", %{conn: conn, door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert html_response(conn, 200)
    end

    test "cannot update another user's door", %{conn: conn, other_door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert html_response(conn, 403) =~ "Forbidden"
    end

    test "can update their own door", %{conn: conn, door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :show, door)
    end

    test "sees form errors when updating a door with invalid data", %{conn: conn, door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @invalid_attrs)
      assert html_response(conn, 200) =~ "Oops"
    end

    test "cannot delete another user's door", %{conn: conn, other_door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    test "can delete their own door", %{conn: conn, door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert redirected_to(conn) == Routes.door_path(conn, :index)
    end

    test "cannot open another user's door", %{conn: conn, other_door: other_door} do
      conn = post(conn, Routes.door_path(conn, :open, other_door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    test "can open their own door", %{conn: conn, door: door} do
      conn = post(conn, Routes.door_path(conn, :open, door))
      assert redirected_to(conn) == Routes.door_path(conn, :index)
    end

    test "cannot close another user's door", %{conn: conn, other_door: other_door} do
      conn = post(conn, Routes.door_path(conn, :close, other_door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    test "can close their own door", %{conn: conn, door: door} do
      conn = post(conn, Routes.door_path(conn, :close, door))
      assert redirected_to(conn) == Routes.door_path(conn, :index)
    end
  end

  describe "admins" do
    setup [:add_admin_session, :add_other_user, :add_other_door]

    test "can list another user's doors", %{conn: conn, other_user: other_user} do
      extra_door = door_fixture(other_user)
      conn = get(conn, Routes.door_path(conn, :index))
      assert html_response(conn, 200) =~ extra_door.name
    end

    test "can see a form to create another user's door", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :new))
      assert html_response(conn, 200) =~ "Owner"
    end

    test "can create another user's door", %{conn: conn, other_user: other_user} do
      create_attrs = Map.put(@create_attrs, :user_id, other_user.id)
      conn = post(conn, Routes.door_path(conn, :create), door: create_attrs)
      assert %{id: id} = redirected_params(conn)
      new_door = Access.get_door!(id)
      assert new_door.user_id == other_user.id
    end

    test "can show another user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert html_response(conn, 200)
    end

    test "can see a form to edit another user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert html_response(conn, 200)
    end

    test "can update another user's door", %{conn: conn, other_door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :show, door)
    end

    test "can delete a door", %{conn: conn, other_door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert redirected_to(conn) == Routes.door_path(conn, :index)
    end
  end

end
