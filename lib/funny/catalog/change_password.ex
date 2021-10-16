defmodule Funny.Catalog.ChangePassword do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :old_password, :string
    field :new_password, :string
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:old_password, :new_password])
    |> validate_required([:old_password, :new_password])
    |> validate_length(:new_password, min: 4, message: "password has to be at least 4 characters")
  end
end
