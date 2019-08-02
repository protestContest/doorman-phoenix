# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :doorman,
  ecto_repos: [Doorman.Repo],
  twilio_client: Doorman.TwilioClient

# Configures the endpoint
config :doorman, DoormanWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "k6TaC7s2J1sTYoJyAiyUXjtSclt817BmI5/5mN22EGGVeuPU2z8N8qe8dcSJvSEN",
  render_errors: [view: DoormanWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Doorman.PubSub, adapter: Phoenix.PubSub.PG2]

# Phauxth authentication configuration
config :phauxth,
  user_context: Doorman.Accounts,
  crypto_module: Argon2,
  token_module: DoormanWeb.Auth.Token

# Mailer configuration
config :doorman, DoormanWeb.Mailer,
  adapter: Bamboo.LocalAdapter

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_twilio, account_sid:   System.get_env("TWILIO_ACCOUNT_SID"),
                   auth_token:    System.get_env("TWILIO_AUTH_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
