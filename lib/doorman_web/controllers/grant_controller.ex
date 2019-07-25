defmodule DoormanWeb.GrantController do
  use DoormanWeb, :controller

  import DoormanWeb.Authorize

  alias Doorman.Access
  alias Doorman.Access.Grant
  alias DoormanWeb.DoorView

  plug :user_check
  plug :door_ownership_check when action in [:create]

  def index(%Plug.Conn{assigns: %{current_user: current_user}} = conn, _params) do
    grants = if (current_user.is_admin) do
      Access.list_grants()
    else
      Access.list_grants(current_user)
    end

    render(conn, "index.html", grants: grants)
  end

  def new(conn, _params) do
    changeset = Access.change_grant(%Grant{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"grant" => %{"door_id" => door_id, "duration" => duration} = grant_params}) do
    door = Access.get_door!(door_id)
    grant = Access.open_door(door, String.to_integer(duration))
    conn
    |> put_flash(:info, "Door open until #{DoorView.format_time(grant.timeout)}")
    |> redirect(to: Routes.door_path(conn, :show, grant.door_id))
  end

end
