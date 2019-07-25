defmodule Doorman.Access.Door do
  use Ecto.Schema
  import Ecto.Changeset

  alias Doorman.Accounts.User
  alias Doorman.Access.Grant

  schema "doors" do
    field :forward_number, :string
    field :incoming_number, :string
    field :name, :string
    belongs_to :user, User
    has_many :grants, Grant

    timestamps(type: :utc_datetime)
  end

  def changeset(door, attrs) do
    door
    |> cast(attrs, [:name, :incoming_number, :forward_number, :user_id])
    |> validate_required([:name, :incoming_number, :forward_number])
  end
end
