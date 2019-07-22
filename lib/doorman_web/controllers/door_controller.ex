defmodule DoormanWeb.DoorController do
  use DoormanWeb, :controller

  import DoormanWeb.Authorize

  alias Doorman.Doors
  alias Doorman.Doors.Door
  alias Doorman.Accounts

  plug :user_check
  plug :door_ownership_check

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _params) do
    doors = Doors.list_doors()
    render(conn, "index.html", doors: doors, user: current_user)
  end

  def new(conn, _params) do
    changeset = Doors.change_door(%Door{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(
      %Plug.Conn{assigns: %{current_user: current_user}} = conn,
      %{"door" => door_params}) do

    user = if !is_nil(door_params.user_id) do
      Accounts.get_user(door_params.user_id)
    else
      Accounts.get_user(current_user)
    end

    case Doors.create_door(door_params, user) do
      {:ok, door} ->
        conn
        |> put_flash(:info, "Door created successfully.")
        |> redirect(to: Routes.door_path(conn, :show, door))

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
        |> redirect(to: Routes.door_path(conn, :show, door))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", door: door, changeset: changeset)
    end
  end

  def delete(
      %Plug.Conn{assigns: %{current_user: _current_user}} = conn,
      %{"id" => id }) do

    door = Doors.get_door!(id)
    {:ok, _door} = Doors.delete_door(door)

    conn
    |> put_flash(:info, "Door deleted successfully.")
    |> redirect(to: Routes.door_path(conn, :index))
  end
end
