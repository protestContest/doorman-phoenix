defmodule DoormanWeb.DoorView do
  use DoormanWeb, :view
  use Timex

  alias Doorman.Access.Door
  alias Doorman.Access

  def door_status(%Door{} = door) do
    case Access.door_status(door) do
      :closed -> "Closed"
      :open -> "Open until #{format_time(Access.last_grant(door).timeout)}"
    end
  end

  defp format_time(timestamp) do
    localtime = Timex.Timezone.convert(timestamp, Timex.Timezone.local())
    {:ok, timestr} = Timex.format(localtime, "{h12}:{m} {AM}")
    timestr
  end
end
