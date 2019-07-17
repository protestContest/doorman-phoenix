defmodule DoormanWeb.LayoutView do
  use DoormanWeb, :view

  def current_session(conn) do
    Plug.Conn.get_session(conn, :phauxth_session_id)
  end
end
