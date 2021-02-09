defmodule Funny.Catalog.Person do
  use Ecto.Schema
  use Material.Mutator
  use Material.Querier

  import Ecto.Changeset

  alias Argon2
  alias Funny.Catalog.Joke

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "persons" do
    field :name, :string
    field :username, :string
    field :password, :string
    field :email, :string

    has_many(:jokes, Joke)

    timestamps()
  end

  mutable()
  queryable()

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :username, :password, :email])
    |> validate_required([:name])
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
