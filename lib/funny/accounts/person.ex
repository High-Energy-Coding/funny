defmodule Funny.Accounts.Person do
  use Ecto.Schema
  import Ecto.Changeset

  schema "persons" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
