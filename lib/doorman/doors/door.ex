defmodule Doorman.Doors.Door do
  use Ecto.Schema
  import Ecto.Changeset

  alias Doorman.Accounts.User

  schema "doors" do
    field :forward_number, :string
    field :incoming_number, :string
    field :name, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def create_changeset(door, user, attrs) do
    door
    |> cast(attrs, [:name, :incoming_number, :forward_number])
    |> change(user_id: user.id)
    |> validate_required([:name, :incoming_number, :forward_number])
  end

  def changeset(door, attrs) do
    door
    |> cast(attrs, [:name, :incoming_number, :forward_number])
    |> validate_required([:name, :incoming_number, :forward_number])
  end
end
