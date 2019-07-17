defmodule Doorman.Repo do
  use Ecto.Repo,
    otp_app: :doorman,
    adapter: Ecto.Adapters.Postgres
end
