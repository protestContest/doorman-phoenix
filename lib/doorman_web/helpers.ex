defmodule DoormanWeb.Helpers do
  import Plug.Conn
  import Phoenix.Controller

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
end
