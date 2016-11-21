defmodule Condet.Repo.Migrations.AddRelationships do
  use Ecto.Migration

  def change do
    alter table(:pathassignments) do
      add :destination_id, references(:destinations)
      add :path_id, references(:paths)
    end
  end
end
