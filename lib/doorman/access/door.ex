defmodule Doorman.Access.Door do
  use Ecto.Schema
  import Ecto.Changeset

  alias Doorman.Accounts.User
  alias Doorman.Access.Grant
  alias Tzdata

  schema "doors" do
    field :forward_number, :string
    field :incoming_number, :string
    field :name, :string
    field :timezone, :string
    belongs_to :user, User
    has_many :grants, Grant

    timestamps(type: :utc_datetime)
  end

  def changeset(door, attrs) do
    door
    |> cast(attrs, [:name, :incoming_number, :forward_number, :timezone, :user_id])
    |> validate_required([:name, :incoming_number, :forward_number, :timezone])
    |> validate_timezone(:timezone)
  end

  defp validate_timezone(changeset, field) do
    validate_change(changeset, field, fn _, timezone ->
      cond do
        Tzdata.zone_exists?(timezone) -> []
        true -> [{field, "Invalid timezone"}]
      end
    end)
  end

end
