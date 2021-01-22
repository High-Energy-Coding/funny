defmodule Funny.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias Funny.Repo

  alias Funny.Catalog.Person

  @doc """
  Returns the list of persons.

  ## Examples

      iex> list_persons()
      [%Person{}, ...]

  """
  def list_persons do
    Repo.all(Person)
  end

  @doc """
  Gets a single person.

  Raises `Ecto.NoResultsError` if the Person does not exist.

  ## Examples

      iex> get_person!(123)
      %Person{}

      iex> get_person!(456)
      ** (Ecto.NoResultsError)

  """
  def get_person!(id), do: Repo.get!(Person, id)

  @doc """
  Creates a person.

  ## Examples

      iex> create_person(%{field: value})
      {:ok, %Person{}}

      iex> create_person(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_person(attrs \\ %{}) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a person.

  ## Examples

      iex> update_person(person, %{field: new_value})
      {:ok, %Person{}}

      iex> update_person(person, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_person(%Person{} = person, attrs) do
    person
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a person.

  ## Examples

      iex> delete_person(person)
      {:ok, %Person{}}

      iex> delete_person(person)
      {:error, %Ecto.Changeset{}}

  """
  def delete_person(%Person{} = person) do
    Repo.delete(person)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.

  ## Examples

      iex> change_person(person)
      %Ecto.Changeset{data: %Person{}}

  """
  def change_person(%Person{} = person, attrs \\ %{}) do
    Person.changeset(person, attrs)
  end

  alias Funny.Catalog.Joke

  @doc """
  Returns the list of jokes.

  ## Examples

      iex> list_jokes()
      [%Joke{}, ...]

  """
  def list_jokes do
    Repo.all(Joke)
  end

  @doc """
  Gets a single joke.

  Raises `Ecto.NoResultsError` if the Joke does not exist.

  ## Examples

      iex> get_joke!(123)
      %Joke{}

      iex> get_joke!(456)
      ** (Ecto.NoResultsError)

  """
  def get_joke!(id), do: Repo.get!(Joke, id)

  @doc """
  Creates a joke.

  ## Examples

      iex> create_joke(%{field: value})
      {:ok, %Joke{}}

      iex> create_joke(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_joke(attrs \\ %{}) do
    %Joke{}
    |> Joke.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a joke.

  ## Examples

      iex> update_joke(joke, %{field: new_value})
      {:ok, %Joke{}}

      iex> update_joke(joke, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_joke(%Joke{} = joke, attrs) do
    joke
    |> Joke.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a joke.

  ## Examples

      iex> delete_joke(joke)
      {:ok, %Joke{}}

      iex> delete_joke(joke)
      {:error, %Ecto.Changeset{}}

  """
  def delete_joke(%Joke{} = joke) do
    Repo.delete(joke)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking joke changes.

  ## Examples

      iex> change_joke(joke)
      %Ecto.Changeset{data: %Joke{}}

  """
  def change_joke(%Joke{} = joke, attrs \\ %{}) do
    Joke.changeset(joke, attrs)
  end
end
