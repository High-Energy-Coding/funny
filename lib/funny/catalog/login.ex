defmodule Funny.Catalog.Login do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :email, :string
    field :password, :string
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/, message: "log the heck back in with your email now please")
    |> validate_length(:password, min: 4, message: "password has to be at least 4 characters")
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
