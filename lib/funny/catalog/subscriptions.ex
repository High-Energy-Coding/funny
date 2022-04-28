defmodule Funny.Catalog.Subscription do
  use Ecto.Schema
  use Material.Mutator
  use Material.Querier

  import Ecto.Changeset

  alias Funny.Catalog.Person
  alias __MODULE__.Keys

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subscriptions" do
    field :endpoint, :string
    field :expirationTime, :string
    embeds_one :keys, Keys

    belongs_to(:person, Person)
    timestamps()
  end

  mutable()
  queryable()

  defmodule Keys do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field :auth, :string
      field :p256dh, :string
    end

    def changeset(keys \\ %__MODULE__{}, attrs \\ %{}) do
      keys
      |> cast(attrs, [:auth, :p256dh])
      |> validate_required([:auth, :p256dh])
    end
  end

  def changeset(subscription \\ %__MODULE__{}, attrs \\ %{}) do
    subscription
    |> cast(attrs, [:person_id, :endpoint, :expirationTime])
    |> cast_embed(:keys)
    |> validate_required([:endpoint, :person_id])
  end
end
