defmodule Doorman.Access.Grant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Doorman.Access.Door

  schema "grants" do
    field :timeout, :utc_datetime
    belongs_to :door, Door

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(grant, attrs) do
    grant
    |> cast(attrs, [:timeout, :door_id])
    |> validate_required([:timeout, :door_id])
    |> foreign_key_constraint(:door_id)
  end

  def create_changeset(grant, attrs) do
    grant
    |> cast(attrs, [:timeout, :door_id])
    |> validate_required([:timeout, :door_id])
    |> foreign_key_constraint(:door_id)
  end
end
