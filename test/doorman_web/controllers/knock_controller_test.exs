defmodule DoormanWeb.KnockControllerTest do
  use DoormanWeb.ConnCase

  import DoormanWeb.DoorTestHelpers

  setup %{conn: conn} do
    conn = conn |> bypass_through(DoormanWeb.Router, [:browser]) |> get("/")
    {:ok, %{conn: conn}}
  end

  test "knocking on a closed door will forward the call", %{conn: conn} do
    door = door_fixture()
    _grant = grant_fixture(:closed, door)
    conn = get(conn, Routes.knock_path(conn, :knock, To: door.incoming_number))
    assert html_response(conn, 200) =~ "Dial"
  end

  test "knocking on an open door will return the open code", %{conn: conn} do
    door = door_fixture()
    _grant = grant_fixture(:open, door)
    conn = get(conn, Routes.knock_path(conn, :knock, To: door.incoming_number))
    assert html_response(conn, 200) =~ "Play digits=\"9\""
  end

end
