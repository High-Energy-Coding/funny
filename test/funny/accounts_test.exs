defmodule Funny.AccountsTest do
  use Funny.DataCase

  alias Funny.Accounts
  alias Funny.Catalog.Person
  alias Funny.Catalog.Family

  describe "register_person/1" do
    test "happy path" do
      refute Person.get_by(%{username: "rmarsh"})
      refute Family.get_by(%{name: "Marsh"})

      assert {:ok, _} =
               Accounts.register_person(%{
                 "first_name" => "Randy",
                 "family_name" => "Marsh",
                 "email" => "rmarsh@email.com",
                 "username" => "rmarsh",
                 "password" => "1234"
               })

      assert %Person{} = Person.get_by(%{username: "rmarsh"})
      assert %Family{} = Family.get_by(%{name: "Marsh"})
    end
  end
end
