defmodule Doorman.TwilioClient.Mock do

  def create_number(_name) do
    %{
      "phone_number" => "+15005550006",
      "sid" => "PNXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    }
  end

end
