defmodule Doorman.Repo.Migrations.CreateDoors do
  use Ecto.Migration

  def change do
    create table(:doors) do
      add :name, :string
      add :incoming_number, :string
      add :forward_number, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:doors, [:user_id])
    create index(:doors, [:incoming_number])
  end
end
