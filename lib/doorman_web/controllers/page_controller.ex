defmodule DoormanWeb.PageController do
  use DoormanWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
