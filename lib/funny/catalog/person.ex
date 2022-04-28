defmodule Funny.Catalog.Person do
  use Ecto.Schema
  use Material.Mutator
  use Material.Querier

  import Ecto.Changeset

  alias Argon2
  alias Funny.Catalog.Joke
  alias Funny.Catalog.Family
  alias Funny.Catalog.Subscription

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "persons" do
    field :name, :string
    field :password, :string
    field :email, :string

    has_many(:jokes, Joke)
    has_many(:subscriptions, Subscription)

    belongs_to(:family, Family)

    timestamps()
  end

  mutable()
  queryable()

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :password, :email, :family_id])
    |> validate_required([])
    |> put_password_hash()
  end

  def new_register_changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :password, :email, :family_id])
    |> validate_required([:name, :password, :email])
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/@/, message: "valid email must contain an @")
    |> unique_constraint(:email)
    |> validate_length(:password,
      min: 4,
      message: "password should be at least like 4 characters. cmon"
    )
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
