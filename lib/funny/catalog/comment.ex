defmodule Funny.Catalog.Comment do
  use Ecto.Schema
  use Material.Mutator
  use Material.Querier

  import Ecto.Changeset

  alias Funny.Catalog.Person
  alias Funny.Catalog.Joke

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :content, :string

    belongs_to(:person, Person)
    belongs_to(:joke, Joke)
    timestamps()
  end

  mutable()
  queryable()

  def new_changeset() do
    %__MODULE__{}
    |> cast(%{}, [])
  end

  def changeset(comment \\ %__MODULE__{}, attrs \\ %{}) do
    comment
    |> cast(attrs, [:content, :person_id, :joke_id])
    |> validate_required([:content, :person_id, :joke_id])
  end
end
