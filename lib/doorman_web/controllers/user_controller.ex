defmodule DoormanWeb.UserController do
  use DoormanWeb, :controller

  import DoormanWeb.Authorize

  alias Phauxth.Log
  alias Doorman.{Accounts, Accounts.User, Repo}
  alias DoormanWeb.{Auth.Token, Email}

  # the following plugs are defined in the controllers/authorize.ex file
  plug :admin_check when action in [:index, :delete]
  plug :id_check when action in [:show, :edit, :update]

  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    key = Token.sign(%{"email" => email})
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})

        Email.confirm_request(email, key)


        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = if !is_nil(user) and id == to_string(user.id), do: user, else: Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

  def edit(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, %{"id" => id}) do
    user = Repo.get(User, id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, %{"user" => user_params, "id" => id}) do
    user = Repo.get(User, id)
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, %{"id" => id}) do
    user = Repo.get(User, id)
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end
end
