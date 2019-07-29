defmodule Doorman.Repo.Migrations.AddTimezoneToDoors do
  use Ecto.Migration

  def change do
    alter table(:doors) do
      add :timezone, :string, default: "Etc/UTC"
    end
  end
end
