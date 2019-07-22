defmodule DoormanWeb.GrantController do
  use DoormanWeb, :controller

  import DoormanWeb.Authorize

  alias Doorman.Doors
  alias Doorman.Doors.Grant

  plug :user_check

  def index(conn, _params) do
    grants = Doors.list_grants()
    render(conn, "index.html", grants: grants)
  end

  def new(conn, _params) do
    changeset = Doors.change_grant(%Grant{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"grant" => grant_params}) do
    case Doors.create_grant(grant_params) do
      {:ok, grant} ->
        conn
        |> put_flash(:info, "Grant created successfully.")
        |> redirect(to: Routes.grant_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

end
