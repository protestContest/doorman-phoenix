defmodule DoormanWeb.DoorControllerTest do
  use DoormanWeb.ConnCase

  import DoormanWeb.AuthTestHelpers

  alias Doorman.Doors

  @create_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "some name"}
  @update_attrs %{forward_number: "some updated forward_number", incoming_number: "some updated incoming_number", name: "some updated name"}
  @invalid_attrs %{forward_number: nil, incoming_number: nil, name: nil}

  setup %{conn: conn} do
    conn = conn |> bypass_through(DoormanWeb.Router, [:browser]) |> get("/")
    {:ok, %{conn: conn}}
  end

  defp add_other_door(%{other_user: user}) do
    {:ok, door} = Doors.create_door(@create_attrs, user)
    {:ok, %{other_door: door}}
  end

  defp add_door(%{user: user}) do
    {:ok, door} = Doors.create_door(@create_attrs, user)
    {:ok, %{door: door}}
  end

  describe "guests" do
    setup [:add_other_user, :add_other_door]

    @tag :index
    test "cannot list a user's doors", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :index))
      assert redirected_to_login(conn)
    end

    @tag :new
    test "cannot see a form to create a new door", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.door_path(conn, :new))
      assert redirected_to_login(conn)
    end

    @tag :create
    test "cannot create a user's door", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @create_attrs)
      assert redirected_to_login(conn)
    end

    @tag :show
    test "cannot show a user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert redirected_to_login(conn)
    end

    @tag :edit
    test "cannot see a form to edit a door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert redirected_to_login(conn)
    end

    @tag :update
    test "cannot update a user's door", %{conn: conn, other_door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert redirected_to_login(conn)
    end

    @tag :delete
    test "cannot delete a door", %{conn: conn, other_door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert redirected_to_login(conn)
    end
  end

  describe "normal users" do
    setup [:add_user_session, :add_door, :add_other_user, :add_other_door]

    @tag :index
    test "cannot list another user's doors", %{conn: conn, other_door: other_door} do
      conn = get(conn, Routes.door_path(conn, :index))
      response = html_response(conn, 200)
      refute response =~ other_door.name
    end

    @tag :index
    test "can list their own doors", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :index))
      assert html_response(conn, 200)
    end

    @tag :new
    test "can see a form to create their own door", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :new))
      assert html_response(conn, 200) =~ "New Door"
    end

    @tag :create
    test "cannot create another user's door", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @create_attrs)
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :create
    test "can create their own door", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.door_path(conn, :show, id)
    end

    @tag :create
    test "sees form errors when creating a door with invalid data", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @invalid_attrs)
      assert html_response(conn, 200) =~ "Oops"
    end

    @tag :show
    test "cannot show another user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :show
    test "can show their own door", %{conn: conn, door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert html_response(conn, 200)
    end

    @tag :edit
    test "cannot see a form to edit another user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :edit
    test "can see a form to edit their own door", %{conn: conn, door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert html_response(conn, 200)
    end

    @tag :update
    test "cannot update another user's door", %{conn: conn, other_door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :update
    test "can update their own door", %{conn: conn, door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :show, door)
    end

    @tag :update
    test "sees form errors when updating a door with invalid data", %{conn: conn, door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @invalid_attrs)
      assert html_response(conn, 200) =~ "Oops"
    end

    @tag :delete
    test "cannot delete another user's door", %{conn: conn, other_door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :delete
    test "can delete their own door", %{conn: conn, door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert redirected_to(conn) == Routes.door_path(conn, :index)
    end
  end

  describe "admins" do
    setup [:add_admin_session, :add_other_user, :add_other_door]

    @tag :index
    test "can list another user's doors", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :index))
      assert html_response(conn, 200)
    end

    @tag :new
    test "can see a form to create another user's door", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :new))
      assert html_response(conn, 200) =~ "User"
    end

    @tag :create
    test "can create a user's door", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.door_path(conn, :show, id)
    end

    @tag :show
    test "can show a user's door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :show, door))
      assert html_response(conn, 200)
    end

    @tag :edit
    test "can see a form to edit a door", %{conn: conn, other_door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert html_response(conn, 200)
    end

    @tag :update
    test "can update a user's door", %{conn: conn, other_door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :show, door)
    end

    @tag :delete
    test "can delete a door", %{conn: conn, other_door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert redirected_to(conn) == Routes.door_path(conn, :index)
    end
  end

end
