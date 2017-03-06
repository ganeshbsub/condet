defmodule Condet.Repo.Migrations.AddCongestion do
  use Ecto.Migration

  def change do
    create table(:congestion) do
      add :ipv4_v6, :string
      add :path_id, :string

      timestamps()
    end
  end
end
