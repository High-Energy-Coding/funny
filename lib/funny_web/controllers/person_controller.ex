defmodule FunnyWeb.PersonController do
  use FunnyWeb, :controller

  alias Funny.Catalog
  alias Funny.Context
  alias Funny.Catalog.Person

  action_fallback FunnyWeb.FallbackController

  def index(conn, _params) do
    %Person{family_id: family_id} = person = Guardian.Plug.current_resource(conn)
    context = %Context{actor: person}

    case Catalog.list_persons(%{family_id: family_id}, context) do
      {:ok, persons} -> render(conn, "index.json", persons: persons)
    end
  end

  def edit(conn, _params) do
    %Person{} = person = Guardian.Plug.current_resource(conn)
    render(conn, "person.json", person: person)
  end

  def update(conn, params) do
    %Person{} = person = Guardian.Plug.current_resource(conn)
    context = %Context{actor: person}

    case Catalog.edit_person(person, params, context) do
      {:ok, %Person{} = person} ->
        render(conn, "person.json", person: person)

      {:error, changeset} ->
        put_status(conn, 400) |> render("400.json", changeset: changeset)
    end
  end
end
