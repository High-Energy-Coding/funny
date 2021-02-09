defmodule Funny.Catalog.Family do
  use Ecto.Schema
  use Material.Mutator
  use Material.Querier

  import Ecto.Changeset

  alias Funny.Catalog.Person

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "families" do
    field :name, :string

    has_many(:persons, Person)

    has_many(:jokes, through: [:persons, :jokes])

    timestamps()
  end

  mutable()
  queryable()

  @doc false
  def changeset(family, attrs) do
    family
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
