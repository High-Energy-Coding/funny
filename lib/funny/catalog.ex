defmodule Funny.Catalog do
  @moduledoc """
  I stole context from atlas. 
  In atlas in makes sense that its a "catalog." Kind of like the old book of listings at
  blockbuster. No creates, no updates. 

  That doesn't necessarily work here. there almost needs to be a "user" context that includes
  all crud things. 

  Might leave context name for now. 
  The Catalog context.
  """

  import Ecto.Query, warn: false

  alias Funny.Catalog.Person
  alias Funny.Catalog.Joke
  alias Funny.Context

  @doc """
  Fetch a single person by given criteria.
  """
  @spec fetch_person(map, Context.t()) :: {:ok, Person.t()} | {:error, :not_found}
  def fetch_person(criteria, context) do
    with %Person{} = record <- Person.get_by(criteria, context: context) do
      {:ok, record}
    else
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Filter multiple persons by given criteria.
  """
  @spec list_persons(map, Context.t()) :: {:ok, list(Person.t())}
  def list_persons(criteria, context) do
    with records when is_list(records) <- Person.list(criteria, context: context) do
      {:ok, records}
    end
  end

  @doc """
  Fetch a single joke by given criteria.
  """
  @spec fetch_joke(map, Context.t()) :: {:ok, Joke.t()} | {:error, :not_found}
  def fetch_joke(criteria, context) do
    with %Joke{} = record <- Joke.get_by(criteria, context: context) do
      {:ok, record}
    else
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Creates a single joke by given criteria.
  """
  @spec create_joke(map, Context.t()) :: {:ok, Joke.t()} | {:error, any()}
  def create_joke(new_joke, context) do
    Joke.insert(new_joke, context: context)
  end

  @doc """
  Delete a single joke by given criteria.
  """
  @spec delete_joke(map, Context.t()) :: {:ok, Joke.t()} | {:error, any()}
  def delete_joke(criteria, context) do
    Joke.get_by(criteria, context: context) |> Joke.delete()
  end

  @doc """
  Filter multiple jokes by given criteria.
  """
  @spec list_jokes(map, Context.t()) :: {:ok, list(Joke.t())}
  def list_jokes(criteria, context) do
    with records when is_list(records) <- Joke.list(criteria, context: context) do
      {:ok, records}
    end
  end
end
