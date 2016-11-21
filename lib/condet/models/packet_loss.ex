defmodule Condet.PacketLoss do
  use Ecto.Schema
  import Ecto.Changeset

  schema "packetloss" do
    field :packets_sent, :integer
    field :packets_received, :integer
    field :packet_loss, :float
    field :last_update, Ecto.DateTime
    field :last_update_type, :boolean, default: false

    belongs_to :pathassignment, Condet.PathAssignment
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:pathassignment_id, :packets_sent, :packets_received, :packet_loss, :last_update, :last_update_type])
    |> validate_required([:pathassignment_id, :packets_sent, :packets_received, :packet_loss, :last_update, :last_update_type])
  end
end
