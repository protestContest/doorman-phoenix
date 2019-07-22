defmodule DoormanWeb.Authorize do
  @moduledoc """
  Functions to help with authorization.

  See the [Authorization wiki page](https://github.com/riverrun/phauxth/wiki/Authorization)
  for more information and examples about authorization.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias DoormanWeb.Router.Helpers, as: Routes
  alias Doorman.Accounts.User
  alias Doorman.Doors

  @doc """
  Plug to only allow authenticated users to access the resource.

  See the user controller for an example.
  """
  def user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    need_login(conn)
  end

  def user_check(conn, _opts), do: conn

  def admin_check(%Plug.Conn{assigns: %{current_user: %User{is_admin: true}}} = conn, _opts), do: conn

  def admin_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    need_login(conn)
  end

  def admin_check(conn, _opts) do
    need_admin(conn)
  end

  @doc """
  Plug to only allow unauthenticated users to access the resource.

  See the session controller for an example.
  """
  def guest_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn

  def guest_check(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts) do
    conn
    |> put_flash(:error, "You need to log out to view this page")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end

  @doc """
  Plug to only allow authenticated users with the correct id to access the resource.

  See the user controller for an example.
  """
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: need_login(conn)

  def id_check(
        %Plug.Conn{params: %{"id" => id}, assigns: %{current_user: current_user}} = conn,
        _opts
      ), do: check_id(conn, current_user, id)

  def door_ownership_check(
        %Plug.Conn{params: %{"id" => id}, assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    door = Doors.get_door!(id)
    check_id(conn, current_user, door.user_id)
  end

  defp check_id(conn, user, id) do
    if to_string(id) == to_string(user.id) || user.is_admin do
      conn
    else
      forbidden(conn)
    end
  end

  defp need_login(conn) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, "You need to log in to view this page")
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end

  defp need_admin(%Plug.Conn{assigns: %{current_user: nil}} = conn) do
    conn
    |> put_session(:request_path, current_path(conn))
    |> put_flash(:error, "You need to log in to view this page")
    |> redirect(to: Routes.session_path(conn, :new))
    |> halt()
  end

  defp need_admin(conn), do: forbidden(conn)

  defp forbidden(conn) do
    conn
    |> put_status(:forbidden)
    |> put_view(DoormanWeb.ErrorView)
    |> render("403.html")
    |> halt()
  end
end
