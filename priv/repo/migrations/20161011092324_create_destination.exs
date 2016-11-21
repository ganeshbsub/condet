defmodule Condet.Repo.Migrations.CreateDestination do
  use Ecto.Migration

  def change do
    create table(:destinations) do
      add :asn, :integer
      add :ipv4_v6, :string
      add :geolocation, :string
      add :packet_type, :string
      add :service, :string

      timestamps()
    end

  end
end
