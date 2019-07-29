defmodule DoormanWeb.DoorViewTest do
  use DoormanWeb.ConnCase, async: true

  import DoormanWeb.DoorTestHelpers
  import DoormanWeb.DoorView

  test "grant_duration/1 formats a grant's duration" do
    door = door_fixture()
    grant1 = grant_fixture(3601, door)
    grant2 = grant_fixture(3661, door)
    assert grant_duration(grant1) == "1hr"
    assert grant_duration(grant2) == "1hr 1min"
  end
end
