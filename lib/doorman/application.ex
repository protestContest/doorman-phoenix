defmodule Doorman.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Doorman.Repo,
      # Start the endpoint when the application starts
      DoormanWeb.Endpoint
      # Starts a worker by calling: Doorman.Worker.start_link(arg)
      # {Doorman.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Doorman.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DoormanWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
