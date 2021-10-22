defmodule Funny.Catalog.Joke do
  use Ecto.Schema
  use Material.Mutator
  use Material.Querier

  import Ecto.Changeset

  alias Funny.Catalog.Person

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "jokes" do
    field :content, :string
    field :image_url, :string

    belongs_to(:person, Person)
    timestamps()
  end

  mutable()
  queryable()

  @doc false
  def new_changeset() do
    %__MODULE__{}
    |> cast(%{}, [])
  end

  def changeset(joke \\ %__MODULE__{}, attrs \\ %{}) do
    joke
    |> cast(attrs, [:content, :person_id, :image_url])
    |> validate_required([:content, :person_id])
  end
end
