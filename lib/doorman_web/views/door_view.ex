defmodule DoormanWeb.DoorView do
  use DoormanWeb, :view
  use Timex

  alias Doorman.Access.{Door, Grant}
  alias Doorman.Access
  alias Doorman.Accounts

  def door_status(%Door{} = door) do
    case Access.door_status(door) do
      :closed -> "Closed"
      :open -> "Open until #{format_time(Access.last_grant(door).timeout)}"
    end
  end

  def grant_time(%Grant{} = grant) do
    localtime = Timezone.convert(grant.timeout, Timezone.local())
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

  defp format_time(timestamp) do
    localtime = Timex.Timezone.convert(timestamp, Timex.Timezone.local())
    {:ok, timestr} = Timex.format(localtime, "{h12}:{m} {AM}")
    timestr
  end
end
