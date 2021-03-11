defmodule FunnyWeb.JokeController do
  use FunnyWeb, :controller

  alias Funny.Catalog
  alias Funny.Catalog.Joke
  alias Funny.Catalog.Person
  alias Funny.Context

  action_fallback FunnyWeb.FallbackController

  def index(conn, _params) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    case Catalog.list_jokes(
           %{with_person: true, family_id: family_id, latest_first: true},
           %Context{}
         ) do
      {:ok, jokes} -> render(conn, "index.json", jokes: jokes)
    end
  end

  def create(conn, %{"joke" => joke_params}) do
    with {:ok, %Joke{} = joke} <- Catalog.create_joke(joke_params, %Context{}) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.joke_path(conn, :show, joke))
      |> text("gucci")
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.fetch_joke(%{id: id}, %Context{}) do
      {:ok, joke} -> render(conn, "show.json", joke: joke)
      {:error, :not_found} -> render(conn, "404.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    case Catalog.delete_joke(%{id: id}, %Context{}) do
      {:ok, _} -> json(conn, id)
      {:error, _} -> render(conn, "poop.json")
    end
  end
end
