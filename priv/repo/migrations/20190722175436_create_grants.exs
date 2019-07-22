defmodule Doorman.Repo.Migrations.CreateGrants do
  use Ecto.Migration

  def change do
    create table(:grants) do
      add :timeout, :naive_datetime
      add :door_id, references(:doors, on_delete: :delete_all)

      timestamps()
    end

    create index(:grants, [:door_id])
  end
end
