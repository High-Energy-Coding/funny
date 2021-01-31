defmodule FunnyWeb.JokeController do
  use FunnyWeb, :controller

  alias Funny.Catalog
  alias Funny.Catalog.Joke
  alias Funny.Context

  action_fallback FunnyWeb.FallbackController

  def index(conn, _params) do
    case Catalog.list_jokes(%{with_person: true}, %Context{}) do
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
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, _} -> render(conn, "poop.json")
    end
  end
end
