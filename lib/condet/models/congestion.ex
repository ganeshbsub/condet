defmodule Condet.Congestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "congestion" do
    field :ipv4_v6, :string
    field :path_id, :integer
    field :type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:ipv4_v6, :path_id, :type])
    |> validate_required([:ipv4_v6, :path_id, :type])
  end
end