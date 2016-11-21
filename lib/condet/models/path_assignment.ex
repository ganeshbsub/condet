defmodule Condet.PathAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pathassignments" do
    field :hop_number, :integer
    belongs_to :path, Condet.Path
    belongs_to :destination, Condet.Destination

    has_one :rttdetails, Condet.RTTDetails
    has_one :packetloss, Condet.PacketLoss
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:hop_number, :destination_id, :path_id])
    |> validate_required([:hop_number])
  end
end
