defmodule DoormanWeb.KnockController do
  use DoormanWeb, :controller

  alias Doorman.Access
  alias Doorman.Access.Door
  alias Doorman.Accounts

  def knock(conn, %{"To" => incoming_num} = params) do
    door = Access.get_door_by_number!(incoming_num)
    if Access.door_status(door) == :open do
      conn |> put_layout(false) |> render("let_in.html")
    else
      conn |> put_layout(false) |> render("forward.html", forward_number: door.forward_number)
    end
  end

end
