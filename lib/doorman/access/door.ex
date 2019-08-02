defmodule Doorman.Access.Door do
  use Ecto.Schema
  import Ecto.Changeset

  alias Doorman.Accounts.User
  alias Doorman.Access.Grant
  alias Tzdata

  schema "doors" do
    field :name, :string
    field :forward_number, :string
    field :incoming_number, :string
    field :incoming_number_sid, :string
    field :timezone, :string
    belongs_to :user, User
    has_many :grants, Grant

    timestamps(type: :utc_datetime)
  end

  def changeset(door, attrs) do
    door
    |> cast(attrs, [:name, :forward_number, :timezone, :user_id])
    |> validate_required([:name, :forward_number, :timezone])
    |> validate_timezone(:timezone)
  end

  def add_incoming_number(changeset, %{"phone_number" => number, "sid" => sid}) do
    changeset
    |> put_change(:incoming_number, number)
    |> put_change(:incoming_number_sid, sid)
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
