defmodule Condet.RTTDetails do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rttdetails" do
    field :latest, :float
    field :latest_updated_at, Ecto.DateTime
    field :all_time_small, :float
    field :all_time_small_updated_at, Ecto.DateTime
    field :all_time_big, :float
    field :all_time_big_updated_at, Ecto.DateTime
    field :number_of_measurements, :integer
    field :average, :float
    field :average_with_time_weight, :float
    field :last_update_type, :boolean, default: false

    belongs_to :pathassignment, Condet.PathAssignment
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:pathassignment_id, :latest, :latest_updated_at, :all_time_small, :all_time_small_updated_at, :all_time_big, :all_time_big_updated_at, :number_of_measurements, :average, :average_with_time_weight, :last_update_type])
    |> validate_required([:pathassignment_id, :latest, :latest_updated_at, :all_time_small, :all_time_small_updated_at, :all_time_big, :all_time_big_updated_at, :number_of_measurements, :average, :average_with_time_weight, :last_update_type])
  end
end
