defmodule Doorman.Notify do

  def notify_access(door) do
    message = "Someone came in at #{door.name}"
    ExTwilio.Message.create(to: door.forward_number, from: door.incoming_number, body: message)
  end

end
