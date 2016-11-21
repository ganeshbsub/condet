defmodule Condet.Repo.Migrations.CreatePathAssignment do
  use Ecto.Migration

  def change do
    create table(:pathassignemts) do
      add :hop_number, :integer

      timestamps()
    end

  end
end
