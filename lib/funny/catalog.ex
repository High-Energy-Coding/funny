defmodule Funny.Catalog do
  @moduledoc """
  """

  import Ecto.Query, warn: false

  alias Funny.Catalog.Person
  alias Funny.Catalog.Joke
  alias Funny.Context

  @spec fetch_person(map, Context.t()) :: {:ok, Person.t()} | {:error, :not_found}
  def fetch_person(criteria, context) do
    with %Person{} = record <- Person.get_by(criteria, context: context) do
      {:ok, record}
    else
      nil -> {:error, :not_found}
    end
  end

  @spec list_persons(map, Context.t()) :: {:ok, list(Person.t())}
  def list_persons(criteria, context) do
    with records when is_list(records) <- Person.list(criteria, context: context) do
      {:ok, records}
    end
  end

  def edit_person(person, params, _context) do
    Person.update(person, params)
  end

  @spec fetch_joke(map, Context.t()) :: {:ok, Joke.t()} | {:error, :not_found}
  def fetch_joke(criteria, context) do
    with %Joke{} = record <- Joke.get_by(criteria, context: context) do
      {:ok, record}
    else
      nil -> {:error, :not_found}
    end
  end

  @spec create_joke(map, Context.t()) :: {:ok, Joke.t()} | {:error, any()}
  def create_joke(new_joke, context) do
    Joke.insert(new_joke, context: context)
  end

  @spec delete_joke(map, Context.t()) :: {:ok, Joke.t()} | {:error, any()}
  def delete_joke(criteria, context) do
    Joke.get_by(criteria, context: context) |> Joke.delete()
  end

  @spec list_jokes(map, Context.t()) :: {:ok, list(Joke.t())}
  def list_jokes(criteria, context) do
    with records when is_list(records) <- Joke.list(criteria, context: context) do
      {:ok, records}
    end
  end
end
