defmodule DoormanWeb.Router do
  use DoormanWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember, create_session_func: &Doorman.Sessions.create_user_session/1
  end

  scope "/", DoormanWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController
    resources "/doors", DoorController
    get "/doors/:id/confirm", DoorController, :confirm

    resources "/grants", GrantController, only: [:index, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/confirm", ConfirmController, :index
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update

    post "/doors/:id/open", DoorController, :open
    post "/doors/:id/close", DoorController, :close

    get "/knock", KnockController, :knock
  end

end
