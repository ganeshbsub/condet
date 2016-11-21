defmodule Condet.Repo.Migrations.CorrectTableName do
  use Ecto.Migration

  def change do
    rename table(:pathassignemts), to: table(:pathassignments)
  end
end
