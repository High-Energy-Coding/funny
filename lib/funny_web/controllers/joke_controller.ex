defmodule FunnyWeb.JokeController do
  use FunnyWeb, :controller

  alias Funny.Catalog.Joke
  alias Funny.Catalog.Person

  def new(conn, _params) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    person_list =
      Person.list(%{family_id: family_id})
      |> Enum.map(fn x -> {x.name, x.id} end)

    render(conn, "new.html", changeset: Joke.new_changeset(), person_list: person_list)
  end

  def create(conn, %{"joke" => joke_params}) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    joke_params =
      case joke_params["image_attachment"] do
        %Plug.Upload{path: path, content_type: "image/" <> content_type} ->
          s3_url_path = family_id <> "/" <> Ecto.UUID.generate() <> "." <> content_type
          Funny.AWS.put_object(s3_url_path, File.read!(path))
          Map.put(joke_params, "image_url", s3_url_path)

        _ ->
          joke_params
      end

    case Joke.insert(joke_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Joke created successfully.")
        |> redirect(to: Routes.app_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

        person_list =
          Person.list(%{family_id: family_id})
          |> Enum.map(fn x -> {x.name, x.id} end)

        render(conn, "new.html", changeset: changeset, person_list: person_list)
    end
  end

  def show(conn, %{"id" => id}) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    case Joke.get_by(%{id: id, family_id: family_id, with_person: true}) do
      nil -> render(conn, "no_joke_found.html")
      joke -> render(conn, "show.html", joke: joke)
    end
  end

  def edit(conn, %{"id" => id}) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    person_list =
      Person.list(%{family_id: family_id})
      |> Enum.map(fn x -> {x.name, x.id} end)

    joke = Joke.get_by(%{id: id, family_id: family_id})
    changeset = Joke.changeset(joke)
    render(conn, "edit.html", joke: joke, changeset: changeset, person_list: person_list)
  end

  def update(conn, %{"id" => id, "joke" => joke_params}) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)
    joke = Joke.get_by(%{id: id, family_id: family_id})

    case Joke.update(joke, joke_params) do
      {:ok, joke} ->
        conn
        |> put_flash(:info, "Joke updated successfully.")
        |> redirect(to: Routes.joke_path(conn, :show, joke))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", joke: joke, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    Joke.get_by(%{id: id, family_id: family_id})
    |> Joke.delete()

    conn
    |> put_flash(:info, "Joke deleted successfully.")
    |> redirect(to: Routes.app_path(conn, :index))
  end
end
