defmodule FunnyWeb.AppController do
  use FunnyWeb, :controller
  alias Funny.Catalog.Person

  alias Funny.Accounts

  alias Funny.Accounts.Guardian
  alias Funny.Context
  alias Funny.Catalog

  def index(conn, _something) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn) |> IO.inspect()
    IO.inspect(family_id)

    case Catalog.list_jokes(
           %{with_person: true, family_id: family_id, latest_first: true},
           %Context{}
         ) do
      {:ok, jokes} -> render(conn, "index.html", jokes: jokes)
    end
  end

  def sign_in(conn, _something) do
    changeset = Person.changeset(%Person{}, %{})
    render(conn, "sign_in.html", changeset: changeset, action: Routes.app_path(conn, :login))
  end

  def login(conn, %{"person" => %{"username" => username, "password" => password}}) do
    Accounts.authenticate_person(username, password)
    |> case do
      {:ok, person} ->
        conn
        |> Guardian.Plug.remember_me(person)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_status(401)
        |> json(%{poopy: "#{inspect(reason)}"})
    end
  end
end
