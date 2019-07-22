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
    |> cast(attrs, [:timeout])
    |> validate_required([:timeout])
  end
end
