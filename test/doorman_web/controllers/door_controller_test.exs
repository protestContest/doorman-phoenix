defmodule DoormanWeb.DoorControllerTest do
  use DoormanWeb.ConnCase

  alias Doorman.Doors
  alias Doorman.Accounts

  @user_attrs %{email: "asdf@example.com", password: "asdfasdf"}
  @create_attrs %{forward_number: "some forward_number", incoming_number: "some incoming_number", name: "some name"}
  @update_attrs %{forward_number: "some updated forward_number", incoming_number: "some updated incoming_number", name: "some updated name"}
  @invalid_attrs %{forward_number: nil, incoming_number: nil, name: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  def fixture(:door, user) do
    {:ok, door} = Doors.create_door(@create_attrs, user)
    door
  end

  describe "index" do
    test "lists all doors", %{conn: conn} do
      user = fixture(:user)
      conn = get(conn, Routes.user_door_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Doors"
    end
  end

  describe "new door" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.door_path(conn, :new))
      assert html_response(conn, 200) =~ "New Door"
    end
  end

  describe "create door" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.door_path(conn, :show, id)

      conn = get(conn, Routes.door_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Door"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.door_path(conn, :create), door: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Door"
    end
  end

  describe "edit door" do
    setup [:create_door]

    test "renders form for editing chosen door", %{conn: conn, door: door} do
      conn = get(conn, Routes.door_path(conn, :edit, door))
      assert html_response(conn, 200) =~ "Edit Door"
    end
  end

  describe "update door" do
    setup [:create_door]

    test "redirects when data is valid", %{conn: conn, door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @update_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :show, door)

      conn = get(conn, Routes.door_path(conn, :show, door))
      assert html_response(conn, 200) =~ "some updated forward_number"
    end

    test "renders errors when data is invalid", %{conn: conn, door: door} do
      conn = put(conn, Routes.door_path(conn, :update, door), door: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Door"
    end
  end

  describe "delete door" do
    setup [:create_door]

    test "deletes chosen door", %{conn: conn, door: door} do
      conn = delete(conn, Routes.door_path(conn, :delete, door))
      assert redirected_to(conn) == Routes.door_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.door_path(conn, :show, door))
      end
    end
  end

  defp create_door(_) do
    user = fixture(:user)
    door = fixture(:door, user)
    {:ok, door: door, user: user}
  end
end
