defmodule Doorman.Twilio do

  def create_number(name) do
    account_sid = Application.get_env(:ex_twilio, :account_sid)
    auth_token = Application.get_env(:ex_twilio, :auth_token)
    auth_digest = Base.encode64("#{account_sid}:#{auth_token}")
    headers = [{"Authorization", "Basic #{auth_digest}"}, {"Content-Type", "application/x-www-form-urlencoded; charset=utf-8"}]

    callback = "https://doorman.zjm.me/knock"
    body = "AreaCode=206&VoiceUrl=#{URI.encode_www_form(callback)}&VoiceMethod=GET&FriendlyName=#{URI.encode_www_form(name)}"

    {:ok, res} = HTTPoison.post("https://api.twilio.com/2010-04-01/Accounts/#{account_sid}/IncomingPhoneNumbers.json", body, headers)
    Poison.decode!(res.body)
  end

end
