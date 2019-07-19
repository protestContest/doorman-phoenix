defmodule DoormanWeb.PageControllerTest do
  use DoormanWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Doorman"
  end
end
