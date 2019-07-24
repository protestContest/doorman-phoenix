defmodule DoormanWeb.DoorController do
  use DoormanWeb, :controller

  import DoormanWeb.Authorize

  alias Doorman.Access
  alias Doorman.Access.Door
  alias Doorman.Accounts

  plug :user_check
  plug :door_ownership_check when action in [:show, :edit, :update, :delete, :open, :close]

  @default_timeout 1800 # half an hour

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _params) do
    doors = if current_user.is_admin do
      Access.list_doors()
    else
      Access.list_doors(current_user)
    end

    render(conn, "index.html", doors: doors, user: current_user)
  end

  def new(conn, _params) do
    changeset = Access.change_door(%Door{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(
      %Plug.Conn{assigns: %{current_user: current_user}} = conn,
      %{"door" => door_params}) do

    user = if Map.has_key?(door_params, "user_id") and current_user.is_admin do
      Accounts.get_user(door_params["user_id"])
    else
      current_user
    end

    case Access.create_user_door(user, door_params) do
      {:ok, door} ->
        conn
        |> put_flash(:info, "Door created successfully.")
        |> redirect(to: Routes.door_path(conn, :show, door))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    door = Access.get_door!(id)
    grants = Access.recent_grants(door)
    render(conn, "show.html", door: door, grants: grants)
  end

  def edit(conn, %{"id" => id}) do
    door = Access.get_door!(id)
    changeset = Access.change_door(door)
    render(conn, "edit.html", door: door, changeset: changeset)
  end

  def update(
      %Plug.Conn{assigns: %{current_user: _current_user}} = conn,
      %{"id" => id, "door" => door_params}) do

    door = Access.get_door!(id)

    case Access.update_door(door, door_params) do
      {:ok, door} ->
        conn
        |> put_flash(:info, "Door updated successfully.")
        |> redirect(to: Routes.door_path(conn, :show, door))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", door: door, changeset: changeset)
    end
  end

  def delete(
      %Plug.Conn{assigns: %{current_user: _current_user}} = conn,
      %{"id" => id }) do

    door = Access.get_door!(id)
    {:ok, _door} = Access.delete_door(door)

    conn
    |> put_flash(:info, "Door deleted successfully.")
    |> redirect(to: Routes.door_path(conn, :index))
  end

  def open(conn, %{"id" => id}) do
    door = Access.get_door!(id)
    Access.open_door(door, @default_timeout)

    conn
    |> redirect(to: Routes.door_path(conn, :index))
  end

  def close(conn, %{"id" => id}) do
    door = Access.get_door!(id)
    Access.close_door(door)

    conn
    |> redirect(to: Routes.door_path(conn, :index))
  end
end
