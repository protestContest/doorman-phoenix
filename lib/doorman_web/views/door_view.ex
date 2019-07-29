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
    hours = div seconds, 3600
    minutes = div(rem(seconds, 3600), 60)

    cond do
      seconds == 0 -> "-"
      seconds < 3600 -> "#{minutes}min"
      seconds >= 3600 and minutes == 0 -> "#{hours}hr"
      true -> "#{hours}hr #{minutes}min"
    end
  end

  def format_time(timestamp, tz, type \\ :short) do
    localtime = Timezone.convert(timestamp, tz)
    formatstr = if type == :short, do: "{h12}:{m} {AM}", else: "{Mshort} {D} {YYYY} {h12}:{m} {AM}"
    {:ok, timestr} = Timex.format(localtime, formatstr)
    timestr
  end
end
