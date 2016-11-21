defmodule Condet.Repo.Migrations.CreatePath do
  use Ecto.Migration

  def change do
    create table(:paths) do

      timestamps()
    end

  end
end
