defmodule DoormanWeb.DoorView do
  use DoormanWeb, :view
  use Timex

  alias Doorman.Access.{Door, Grant}
  alias Doorman.Access
  alias Doorman.Accounts
  alias DoormanWeb.GrantView

  def door_status(%Door{} = door) do
    case Access.door_status(door) do
      :closed -> "Closed"
      :open -> "Open until #{format_time(Access.last_grant(door).timeout, door.timezone)}"
    end
  end

  def grant_time(%Grant{} = grant) do
    door = Access.get_door!(grant.door_id)
    localtime = Timezone.convert(grant.timeout, door.timezone)
    {:ok, timestr} = Timex.format(localtime, "{Mshort} {D} {YYYY} {h12}:{m} {AM}")
    timestr
  end

  def grant_duration(%Grant{} = grant) do
    seconds = Access.grant_duration(grant)
    minutes = div seconds, 60
    hours = div minutes, 60

    cond do
      seconds == 0 -> "-"
      seconds < 3600 -> "#{minutes}min"
      true -> "#{hours}hr #{minutes}min"
    end
  end

  def format_time(timestamp, tz) do
    localtime = Timezone.convert(timestamp, tz)
    {:ok, timestr} = Timex.format(localtime, "{h12}:{m} {AM}")
    timestr
  end
end
