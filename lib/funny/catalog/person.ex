defmodule Funny.Catalog.Person do
  use Ecto.Schema
  import Ecto.Changeset

  alias Funny.Catalog.Joke

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "persons" do
    field :name, :string

    has_many(:jokes, Joke)

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
