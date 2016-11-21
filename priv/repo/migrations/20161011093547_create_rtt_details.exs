defmodule Condet.Repo.Migrations.CreateRTTDetails do
  use Ecto.Migration

  def change do
    create table(:rttdetails) do
      add :latest, :float
      add :latest_updated_at, :datetime
      add :all_time_small, :float
      add :all_time_small_updated_at, :datetime
      add :all_time_big, :float
      add :all_time_big_updated_at, :datetime
      add :number_of_measurements, :integer
      add :average, :float
      add :average_with_time_weight, :float
      add :last_update_type, :boolean, default: false, null: false

      timestamps()
    end

  end
end
