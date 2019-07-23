defmodule DoormanWeb.GrantControllerTest do
  use DoormanWeb.ConnCase

  import DoormanWeb.AuthTestHelpers
  import DoormanWeb.DoorTestHelpers

  @create_attrs %{timeout: ~N[2010-04-17 14:00:00]}
  # @update_attrs %{timeout: ~N[2011-05-18 15:01:01]}
  # @invalid_attrs %{timeout: nil}

  setup %{conn: conn} do
    conn = conn |> bypass_through(DoormanWeb.Router, [:browser]) |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "guests" do
    @tag :index
    test "cannot list any grants", %{conn: conn} do
      conn = get(conn, Routes.grant_path(conn, :index))
      assert redirected_to_login(conn)
    end

    @tag :new
    test "cannot see a form to create a grant", %{conn: conn} do
      conn = get(conn, Routes.grant_path(conn, :new))
      assert redirected_to_login(conn)
    end

    @tag :create
    test "cannot create a grant", %{conn: conn} do
      conn = post(conn, Routes.grant_path(conn, :create), grant: @create_attrs)
      assert redirected_to_login(conn)
    end
  end

  describe "normal users" do
    setup [
      :add_user_session,
      :add_door,
      :add_open_grant,
      :add_other_user,
      :add_other_door,
      :add_other_grant
    ]

    @tag :index
    test "can list their own grants", %{conn: conn, grant: grant} do
      conn = get(conn, Routes.grant_path(conn, :index))
      assert html_response(conn, 200) =~ to_string(grant.timeout)
    end

    @tag :index
    test "cannot list other users's grants", %{conn: conn, other_grant: other_grant} do
      conn = get(conn, Routes.grant_path(conn, :index))
      refute html_response(conn, 200) =~ to_string(other_grant.timeout)
    end

    @tag :new
    test "can see a form to create a grant", %{conn: conn} do
      conn = get(conn, Routes.grant_path(conn, :new))
      assert html_response(conn, 200) =~ "New Grant"
    end

    @tag :create
    test "can create a grant", %{conn: conn} do
      conn = post(conn, Routes.grant_path(conn, :create), grant: @create_attrs)
      assert redirected_to(conn) == Routes.grant_path(conn, :index)
    end
  end

  describe "admins" do
    setup [
      :add_admin_session,
      :add_door,
      :add_open_grant,
      :add_other_user,
      :add_other_door,
      :add_other_grant
    ]

    @tag :index
    test "can list other users's grants", %{conn: conn, other_grant: other_grant} do
      conn = get(conn, Routes.grant_path(conn, :index))
      assert html_response(conn, 200) =~ to_string(other_grant.timeout)
    end
  end

end
