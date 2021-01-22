defmodule Funny.CatalogTest do
  use Funny.DataCase

  alias Funny.Catalog

  describe "persons" do
    alias Funny.Catalog.Person

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def person_fixture(attrs \\ %{}) do
      {:ok, person} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Catalog.create_person()

      person
    end

    test "list_persons/0 returns all persons" do
      person = person_fixture()
      assert Catalog.list_persons() == [person]
    end

    test "get_person!/1 returns the person with given id" do
      person = person_fixture()
      assert Catalog.get_person!(person.id) == person
    end

    test "create_person/1 with valid data creates a person" do
      assert {:ok, %Person{} = person} = Catalog.create_person(@valid_attrs)
      assert person.name == "some name"
    end

    test "create_person/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_person(@invalid_attrs)
    end

    test "update_person/2 with valid data updates the person" do
      person = person_fixture()
      assert {:ok, %Person{} = person} = Catalog.update_person(person, @update_attrs)
      assert person.name == "some updated name"
    end

    test "update_person/2 with invalid data returns error changeset" do
      person = person_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_person(person, @invalid_attrs)
      assert person == Catalog.get_person!(person.id)
    end

    test "delete_person/1 deletes the person" do
      person = person_fixture()
      assert {:ok, %Person{}} = Catalog.delete_person(person)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_person!(person.id) end
    end

    test "change_person/1 returns a person changeset" do
      person = person_fixture()
      assert %Ecto.Changeset{} = Catalog.change_person(person)
    end
  end

  describe "jokes" do
    alias Funny.Catalog.Joke

    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}
    @invalid_attrs %{content: nil}

    def joke_fixture(attrs \\ %{}) do
      {:ok, joke} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Catalog.create_joke()

      joke
    end

    test "list_jokes/0 returns all jokes" do
      joke = joke_fixture()
      assert Catalog.list_jokes() == [joke]
    end

    test "get_joke!/1 returns the joke with given id" do
      joke = joke_fixture()
      assert Catalog.get_joke!(joke.id) == joke
    end

    test "create_joke/1 with valid data creates a joke" do
      assert {:ok, %Joke{} = joke} = Catalog.create_joke(@valid_attrs)
      assert joke.content == "some content"
    end

    test "create_joke/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_joke(@invalid_attrs)
    end

    test "update_joke/2 with valid data updates the joke" do
      joke = joke_fixture()
      assert {:ok, %Joke{} = joke} = Catalog.update_joke(joke, @update_attrs)
      assert joke.content == "some updated content"
    end

    test "update_joke/2 with invalid data returns error changeset" do
      joke = joke_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_joke(joke, @invalid_attrs)
      assert joke == Catalog.get_joke!(joke.id)
    end

    test "delete_joke/1 deletes the joke" do
      joke = joke_fixture()
      assert {:ok, %Joke{}} = Catalog.delete_joke(joke)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_joke!(joke.id) end
    end

    test "change_joke/1 returns a joke changeset" do
      joke = joke_fixture()
      assert %Ecto.Changeset{} = Catalog.change_joke(joke)
    end
  end
end
