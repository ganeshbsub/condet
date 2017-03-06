defmodule Condet.Repo.Migrations.ModifyCongestion do
  use Ecto.Migration

  def change do
    alter table(:congestion) do
      add :type, :string
    end
  end
end
