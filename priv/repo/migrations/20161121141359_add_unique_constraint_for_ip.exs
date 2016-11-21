defmodule Condet.Repo.Migrations.AddUniqueConstraintForIp do
  use Ecto.Migration

  def change do
    create unique_index(:destinations, [:ipv4_v6])
  end
end
