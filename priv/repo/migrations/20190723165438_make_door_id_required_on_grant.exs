defmodule Doorman.Repo.Migrations.MakeDoorIdRequiredOnGrant do
  use Ecto.Migration

  def change do
    alter table(:grants) do
      modify :door_id, :integer, null: false
    end
  end
end
