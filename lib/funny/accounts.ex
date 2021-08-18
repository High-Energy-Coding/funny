defmodule Funny.Accounts do
  alias Argon2
  alias Funny.Catalog.Person
  alias Funny.Catalog.Family

  def get_person!(id) do
    Person.get_by(%{id: id})
  end

  def authenticate_person(username, plain_text_password) do
    case Person.get_by(%{username: username}) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      person ->
        if Argon2.verify_pass(plain_text_password, person.password) do
          {:ok, person}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def register_person(attrs) do
    # family can be associated later after login
    # {:ok, %{id: new_fam_id}} = Family.insert(%{name: attrs["family_name"]})

    Person.insert(%{
      email: attrs["email"],
      name: attrs["first_name"],
      username: attrs["username"],
      password: attrs["password"]
    })
  end
end
