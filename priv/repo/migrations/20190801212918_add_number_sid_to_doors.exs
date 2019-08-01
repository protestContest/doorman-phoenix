defmodule Doorman.Repo.Migrations.AddNumberSidToDoors do
  use Ecto.Migration

  def change do
    alter table(:doors) do
      add :incoming_number_sid, :string
    end
  end
end
