defmodule Condet.Repo.Migrations.AddRemainingRelationships do
  use Ecto.Migration

  def change do
    alter table(:rttdetails) do
      add :pathassignment_id, references(:pathassignments)
    end

    alter table(:packetloss) do
      add :pathassignment_id, references(:pathassignments)
    end
  end
end
