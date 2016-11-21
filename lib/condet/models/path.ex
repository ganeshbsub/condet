defmodule Condet.Path do
  use Ecto.Schema
  import Ecto.Changeset

  schema "paths" do
    has_many :pathassignments, Condet.PathAssignment
    
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
