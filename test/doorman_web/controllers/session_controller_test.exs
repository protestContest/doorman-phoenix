defmodule DoormanWeb.SessionControllerTest do
  use DoormanWeb.ConnCase

  import DoormanWeb.AuthTestHelpers
  import DoormanWeb.DoorTestHelpers

  @create_attrs %{email: "robin@example.com", password: "reallyHard2gue$$"}
  @invalid_attrs %{email: "robin@example.com", password: "cannotGue$$it"}
  @unconfirmed_attrs %{email: "lancelot@example.com", password: "reallyHard2gue$$"}

  setup %{conn: conn} do
    conn = conn |> bypass_through(DoormanWeb.Router, [:browser]) |> get("/")
    add_user("lancelot@example.com")
    user = add_user_confirmed("robin@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  describe "login form" do
    test "rendering login form fails for user that is already logged in", %{
      conn: conn,
      user: user
    } do
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      conn = get(conn, Routes.session_path(conn, :new))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  describe "create session" do
    test "login succeeds", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), session: @create_attrs)
      refute redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "users are redirected to the door list page if multiple doors exist", %{conn: conn, user: user} do
      _door1 = door_fixture(user)
      _door2 = door_fixture(user)
      conn = post(conn, Routes.session_path(conn, :create), session: @create_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :index)
    end

    test "users are redirected to the door detail page on login if only one door exists", %{conn: conn, user: user} do
      door = door_fixture(user)
      conn = post(conn, Routes.session_path(conn, :create), session: @create_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :show, door)
    end

    test "users are redirected to the new door page on login if no doors exist", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), session: @create_attrs)
      assert redirected_to(conn) == Routes.door_path(conn, :new)
    end

    test "login fails for user that is not yet confirmed", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), session: @unconfirmed_attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "login fails for user that is already logged in", %{conn: conn, user: user} do
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      conn = post(conn, Routes.session_path(conn, :create), session: @create_attrs)
      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end

    # @tag :skip
    test "login fails for invalid password", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), session: @invalid_attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "redirects to previously requested resource", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
      conn = post(conn, Routes.session_path(conn, :create), session: @create_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :edit, user)
    end
  end

  describe "delete session" do
    test "logout succeeds and session is deleted", %{conn: conn, user: user} do
      conn = conn |> add_session(user) |> send_resp(:ok, "/")
      session_id = get_session(conn, :phauxth_session_id)
      conn = delete(conn, Routes.session_path(conn, :delete, session_id))
      assert redirected_to(conn) == Routes.page_path(conn, :index)
      conn = get(conn, Routes.user_path(conn, :index))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end
end
