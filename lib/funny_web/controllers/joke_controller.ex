defmodule FunnyWeb.JokeController do
  use FunnyWeb, :controller

  alias Funny.Catalog
  alias Funny.Catalog.Joke

  action_fallback FunnyWeb.FallbackController

  def index(conn, _params) do
    jokes = Catalog.list_jokes()
    render(conn, "index.json", jokes: jokes)
  end

  def create(conn, %{"joke" => joke_params}) do
    with {:ok, %Joke{} = joke} <- Catalog.create_joke(joke_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.joke_path(conn, :show, joke))
      |> render("show.json", joke: joke)
    end
  end

  def show(conn, %{"id" => id}) do
    joke = Catalog.get_joke!(id)
    render(conn, "show.json", joke: joke)
  end

  def update(conn, %{"id" => id, "joke" => joke_params}) do
    joke = Catalog.get_joke!(id)

    with {:ok, %Joke{} = joke} <- Catalog.update_joke(joke, joke_params) do
      render(conn, "show.json", joke: joke)
    end
  end

  def delete(conn, %{"id" => id}) do
    joke = Catalog.get_joke!(id)

    with {:ok, %Joke{}} <- Catalog.delete_joke(joke) do
      send_resp(conn, :no_content, "")
    end
  end
end
