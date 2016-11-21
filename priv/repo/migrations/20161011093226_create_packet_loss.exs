defmodule Condet.Repo.Migrations.CreatePacketLoss do
  use Ecto.Migration

  def change do
    create table(:packetloss) do
      add :packets_sent, :integer
      add :packets_received, :integer
      add :packet_loss, :float
      add :last_update, :datetime
      add :last_update_type, :boolean, default: false, null: false

      timestamps()
    end

  end
end
