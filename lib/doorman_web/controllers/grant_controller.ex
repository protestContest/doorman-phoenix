defmodule DoormanWeb.GrantController do
  use DoormanWeb, :controller

  import DoormanWeb.Authorize

  alias Doorman.Access
  alias Doorman.Access.Grant

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

  def create(conn, %{"grant" => grant_params}) do
    case Access.create_grant(grant_params) do
      {:ok, _grant} ->
        conn
        |> put_flash(:info, "Grant created successfully.")
        |> redirect(to: Routes.grant_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

end
