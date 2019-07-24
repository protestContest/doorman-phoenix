defmodule Doorman.Repo.Migrations.MakeTimestampsUtc do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :inserted_at, :timestamptz, null: false
      modify :updated_at, :timestamptz, null: false
    end

    alter table(:sessions) do
      modify :inserted_at, :timestamptz, null: false
      modify :updated_at, :timestamptz, null: false
    end

    alter table(:doors) do
      modify :inserted_at, :timestamptz, null: false
      modify :updated_at, :timestamptz, null: false
    end

    alter table(:grants) do
      modify :inserted_at, :timestamptz, null: false
      modify :updated_at, :timestamptz, null: false
    end
  end
end
