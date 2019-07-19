defmodule DoormanWeb.AuthTestHelpers do
  use Phoenix.ConnTest

  import Ecto.Changeset

  alias Doorman.{Accounts, Repo, Sessions}
  alias DoormanWeb.Auth.Token
  alias DoormanWeb.Router.Helpers, as: Routes

  def add_user(email) do
    user = %{email: email, password: "reallyHard2gue$$"}
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def add_admin(email) do
    user = %{email: email, password: "reallyHard2gue$$"}
    {:ok, user} = Accounts.create_user(user)
    Accounts.make_admin(user, true)
    user
  end

  def gen_key(email), do: Token.sign(%{"email" => email})

  def add_user_confirmed(email) do
    email
    |> add_user()
    |> change(%{confirmed_at: now()})
    |> Repo.update!()
  end

  def add_reset_user(email) do
    email
    |> add_user()
    |> change(%{confirmed_at: now()})
    |> change(%{reset_sent_at: now()})
    |> Repo.update!()
  end

  def add_session(conn, user) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end

  def add_user_session(%{conn: conn}) do
    user = add_user("reg@example.com")
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end

  def add_admin_session(%{conn: conn}) do
    user = add_admin("reg@example.com")
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end

  def add_other_user(%{conn: conn}) do
    other_user = add_user("other@example.com")
    {:ok, %{conn: conn, other_user: other_user}}
  end

  def redirected_to_login(conn) do
    redirected_to(conn) == Routes.session_path(conn, :new)
  end

  defp now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
