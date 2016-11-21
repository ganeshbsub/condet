defmodule Condet.Destination do
  use Ecto.Schema
  import Ecto.Changeset

  schema "destinations" do
    field :asn, :integer
    field :ipv4_v6, :string
    field :geolocation, :string
    field :packet_type, :string
    field :service, :string

    has_many :pathassignments, Condet.PathAssignment
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:asn, :ipv4_v6, :geolocation, :packet_type, :service])
    |> validate_required([:ipv4_v6])
    |> unique_constraint(:ipv4_v6)
  end
end
