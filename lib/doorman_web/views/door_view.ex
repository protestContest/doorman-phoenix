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

  def one_day_ago_label(tz) do
    day_ago = DateTime.add(DateTime.utc_now(), -24*3600)
    localtime = Timezone.convert(day_ago, tz)
    formatstr = "{M}/{D} {h12}:{m} {AM}"
    {:ok, timestr} = Timex.format(localtime, formatstr)
    timestr
  end

  def now_label(tz) do
    localtime = Timezone.convert(DateTime.utc_now(), tz)
    formatstr = "{M}/{D} {h12}:{m} {AM}"
    {:ok, timestr} = Timex.format(localtime, formatstr)
    timestr
  end

  def landlord_email_url(door) do
    subject = "Update Intercom Phone Number"
    body = URI.encode("""
Hello!

Would you please update my phone number in the building intercom to #{door.incoming_number}?

Thanks!
""")
    "mailto:?body=#{body}&subject=#{subject}"
  end
end
