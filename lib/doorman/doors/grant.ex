defmodule Doorman.Doors.Grant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Doorman.Doors.Door

  schema "grants" do
    field :timeout, :utc_datetime
    belongs_to :door, Door

    timestamps()
  end

  @doc false
  def changeset(grant, attrs) do
    grant
    |> cast(attrs, [:timeout, :door_id])
    |> validate_required([:timeout, :door_id])
  end

  def create_changeset(grant, door, attrs) do
    grant
    |> cast(attrs, [:timeout, :door_id])
    |> change(door_id: door.id)
    |> validate_required([:timeout, :door_id])
  end
end
