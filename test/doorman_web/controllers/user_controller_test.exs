defmodule DoormanWeb.UserControllerTest do
  use DoormanWeb.ConnCase

  import DoormanWeb.AuthTestHelpers

  alias Doorman.Accounts

  @create_attrs %{email: "bill@example.com", password: "hard2guess"}
  @update_attrs %{email: "william@example.com"}
  @update_to_admin_attrs %{email: "william@example.com", is_admin: "true"}
  @invalid_attrs %{email: nil}

  setup %{conn: conn} do
    conn = conn |> bypass_through(DoormanWeb.Router, [:browser]) |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "guests" do
    setup [:add_other_user]

    @tag :index
    test "cannot list all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert redirected_to_login(conn)
    end

    @tag :new
    test "can see a form to create an account", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New user"
    end

    @tag :create
    test "can create a user with valid data", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert redirected_to_login(conn)
    end

    @tag :create
    test "see form errors when creating a user with invalid data", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New user"
    end

    @tag :show
    test "cannot see a user's profile", %{conn: conn, other_user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert redirected_to_login(conn)
    end

    @tag :edit
    test "cannot see an edit form for other users' accounts", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.user_path(conn, :edit, other_user))
      assert redirected_to_login(conn)
    end

    @tag :update
    test "cannot update other users' accounts", %{conn: conn, other_user: other_user} do
      conn = put(conn, Routes.user_path(conn, :update, other_user), user: @invalid_attrs)
      assert redirected_to_login(conn)
    end

    @tag :delete
    test "cannot delete other users' accounts", %{conn: conn, other_user: other_user} do
      conn = delete(conn, Routes.user_path(conn, :delete, other_user))
      assert redirected_to_login(conn)
      assert Accounts.get_user(other_user.id)
    end
  end

  describe "normal users" do
    setup [:add_user_session, :add_other_user]

    @tag :index
    test "cannot list all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :show
    test "can see their own profile page", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ user.email
    end

    @tag :show
    test "cannot see other users' profile pages", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.user_path(conn, :show, other_user))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :edit
    test "can see an edit form for their account", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit user"
    end

    @tag :edit
    test "cannot see an edit form for other users' accounts", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.user_path(conn, :edit, other_user))
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :edit
    test "cannot see a form input for admin status", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200)
      refute html_response(conn, 200) =~ "Is admin"
    end

    @tag :update
    test "can update their account when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      updated_user = Accounts.get_user(user.id)
      assert updated_user.email == "william@example.com"
      conn = get conn,(Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "william@example.com"
    end

    @tag  :update
    test "see form errors when updating their account with invalid data", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit user"
    end

    @tag :update
    test "cannot update other users' accounts", %{conn: conn, other_user: other_user} do
      conn = put(conn, Routes.user_path(conn, :update, other_user), user: @invalid_attrs)
      assert html_response(conn, 403) =~ "Forbidden"
    end

    @tag :update
    test "cannot make their account an admin", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_to_admin_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)
      updated_user = Accounts.get_user(user.id)
      refute updated_user.is_admin
    end

    @tag :delete
    test "cannot delete other users' accounts", %{conn: conn, other_user: other_user} do
      conn = delete(conn, Routes.user_path(conn, :delete, other_user))
      assert html_response(conn, 403) =~ "Forbidden"
      assert Accounts.get_user(other_user.id)
    end
  end

  describe "admins" do
    setup [:add_admin_session, :add_other_user]

    @tag :index
    test "can list all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing users"
    end

    @tag :show
    test "can see other users' profile pages", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.user_path(conn, :show, other_user))
      assert html_response(conn, 200) =~ other_user.email
    end

    @tag :edit
    test "can see an edit form for other users' accounts", %{conn: conn, other_user: other_user} do
      conn = get(conn, Routes.user_path(conn, :edit, other_user))
      assert html_response(conn, 200) =~ "Edit user"
    end

    @tag :edit
    test "can see a form input for admin status", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Is admin"
    end

    @tag :update
    test "can update other users' accounts", %{conn: conn, other_user: other_user} do
      conn = put(conn, Routes.user_path(conn, :update, other_user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, other_user)
      updated_user = Accounts.get_user(other_user.id)
      assert updated_user.email == "william@example.com"
      conn = get conn,(Routes.user_path(conn, :show, other_user))
      assert html_response(conn, 200) =~ "william@example.com"
    end

    @tag :update
    test "can make another user's account an admin", %{conn: conn, other_user: other_user} do
      conn = put(conn, Routes.user_path(conn, :update, other_user), user: @update_to_admin_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, other_user)
      updated_user = Accounts.get_user(other_user.id)
      assert updated_user.email == "william@example.com"
      assert updated_user.is_admin
      conn = get conn,(Routes.user_path(conn, :show, other_user))
      assert html_response(conn, 200) =~ "william@example.com"
    end

    @tag :delete
    test "can delete other users' accounts", %{conn: conn, other_user: other_user} do
      conn = delete(conn, Routes.user_path(conn, :delete, other_user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)
      refute Accounts.get_user(other_user.id)
    end

  end

end
