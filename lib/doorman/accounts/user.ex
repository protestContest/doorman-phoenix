defmodule Doorman.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Doorman.Sessions.Session
  alias Doorman.Access.Door

  @type t :: %__MODULE__{
    id: integer,
    email: String.t(),
    password_hash: String.t(),
    confirmed_at: DateTime.t() | nil,
    reset_sent_at: DateTime.t() | nil,
    sessions: [Session.t()] | %Ecto.Association.NotLoaded{},
    inserted_at: DateTime.t(),
    updated_at: DateTime.t(),
    is_admin: boolean
  }

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :confirmed_at, :utc_datetime
    field :reset_sent_at, :utc_datetime
    field :is_admin, :boolean
    has_many :sessions, Session, on_delete: :delete_all
    has_many :doors, Door

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unchanged_or_unique_email(user)
  end

  def create_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_email
    |> validate_password(:password)
    |> put_pass_hash
    |> put_change(:is_admin, false)
  end

  def change_admin(%__MODULE__{} = user, is_admin) do
    change(user, %{is_admin: is_admin})
  end

  def change_admin(%Ecto.Changeset{} = changeset, is_admin) do
    change(changeset, %{is_admin: is_admin})
  end

  def confirm_changeset(%__MODULE__{} = user, confirmed_at) do
    change(user, %{confirmed_at: confirmed_at})
  end

  def password_reset_changeset(%__MODULE__{} = user, reset_sent_at) do
    change(user, %{reset_sent_at: reset_sent_at})
  end

  def update_password_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_password(:password)
    |> put_pass_hash()
    |> change(%{reset_sent_at: nil})
  end

  defp unique_email(changeset) do
    changeset
    |> validate_format(
      :email,
      ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}$/
    )
    |> validate_length(:email, max: 255)
    |> unique_constraint(:email)
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Bcrypt or Pbkdf2, change Argon2 to Bcrypt or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}

  defp unchanged_or_unique_email(changeset, user) do
    if changeset.changes[:email] == user.email do
      changeset
    else
      unique_email(changeset)
    end
  end
end
