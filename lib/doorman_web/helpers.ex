defmodule DoormanWeb.Helpers do
  import Plug.Conn
  import Phoenix.Controller

  alias Doorman.Accounts.User
  alias Doorman.Access
  alias DoormanWeb.Router.Helpers, as: Routes

  def redirect_back(%Plug.Conn{} = conn, fallback: fallback_path) do
    referrer = get_req_header(conn, "referer")

    if length(referrer) > 0 do
      conn
      |> redirect(external: hd(referrer))
    else
      conn
      |> redirect(to: fallback_path)
    end
  end


  def user_dashboard(%Plug.Conn{} = conn, %User{} = user) do
    doors = Access.list_doors(user)
    case length(doors) do
      0 -> Routes.door_path(conn, :new)
      1 -> Routes.door_path(conn, :show, hd(doors))
      _ -> Routes.door_path(conn, :index)
    end
  end
end
