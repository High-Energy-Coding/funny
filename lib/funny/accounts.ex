defmodule Funny.Accounts do
  alias Argon2
  alias Funny.Catalog.Person

  def get_person!(id) do
    Person.get_by(%{id: id})
  end

  def email_new_password(email) do
    IO.inspect("pretend i sent an email")

    Person.get_by(%{email: email})
    |> TT.wrap()
    |> TT.map(fn p -> Person.update(p, %{password: "1234"}) end)
  end

  def authenticate_person(email, plain_text_password) do
    case Person.get_by(%{email: email}) do
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
end
