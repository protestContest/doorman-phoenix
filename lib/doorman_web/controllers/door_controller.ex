defmodule DoormanWeb.DoorController do
  use DoormanWeb, :controller

  import DoormanWeb.Authorize

  alias Doorman.Doors
  alias Doorman.Doors.Door
  alias Doorman.Accounts

  plug :user_check
  plug :id_check

  def index(conn, %{"user_id" => user_id}) do
    user = Accounts.get_user(user_id)
    doors = Doors.list_doors()
    render(conn, "index.html", doors: doors, user: user)
  end

  def new(conn, _params) do
    changeset = Doors.change_door(%Door{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(
      %Plug.Conn{assigns: %{current_user: _current_user}} = conn,
      %{"door" => door_params, "user_id" => user_id}) do

    user = Accounts.get_user(user_id)

    case Doors.create_door(door_params, user) do
      {:ok, door} ->
        conn
        |> put_flash(:info, "Door created successfully.")
        |> redirect(to: Routes.user_door_path(conn, :show, user_id, door))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    door = Doors.get_door!(id)
    render(conn, "show.html", door: door)
  end

  def edit(conn, %{"id" => id}) do
    door = Doors.get_door!(id)
    changeset = Doors.change_door(door)
    render(conn, "edit.html", door: door, changeset: changeset)
  end

  def update(
      %Plug.Conn{assigns: %{current_user: _current_user}} = conn,
      %{"id" => id, "door" => door_params}) do

    door = Doors.get_door!(id)

    case Doors.update_door(door, door_params) do
      {:ok, door} ->
        conn
        |> put_flash(:info, "Door updated successfully.")
        |> redirect(to: Routes.user_door_path(conn, :show, door.user_id, door))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", door: door, changeset: changeset)
    end
  end

  def delete(
      %Plug.Conn{assigns: %{current_user: _current_user}} = conn,
      %{"id" => id, "user_id" => user_id}) do

    door = Doors.get_door!(id)
    {:ok, _door} = Doors.delete_door(door)

    conn
    |> put_flash(:info, "Door deleted successfully.")
    |> redirect(to: Routes.user_door_path(conn, :index, user_id))
  end
end
