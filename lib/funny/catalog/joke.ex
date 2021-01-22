defmodule Funny.Catalog.Joke do
  use Ecto.Schema
  import Ecto.Changeset

  alias Funny.Catalog.Person

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "jokes" do
    field :content, :string

    belongs_to(:person, Person)
    timestamps()
  end

  @doc false
  def changeset(joke, attrs) do
    joke
    |> cast(attrs, [:content, :person_id])
    |> validate_required([:content, :person_id])
  end
end
