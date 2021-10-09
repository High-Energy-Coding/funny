defmodule FunnyWeb.AppController do
  use FunnyWeb, :controller
  alias Funny.Catalog.Person
  alias Funny.Catalog.Family

  alias Funny.Accounts

  alias Funny.Accounts.Guardian
  alias Funny.Context
  alias Funny.Catalog

  def index(conn, _something) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    if family_id == nil do
      redirect(conn, to: "/add-family")
    end

    case Catalog.list_jokes(
           %{with_person: true, family_id: family_id, latest_first: true},
           %Context{}
         ) do
      {:ok, jokes} -> render(conn, "index.html", jokes: jokes)
    end
  end

  def add_family(conn, _something) do
    changeset = Family.changeset(%Family{}, %{})
    action = Routes.app_path(conn, :add_family_post)
    render(conn, "add_family.html", changeset: changeset, action: action)
  end

  def add_family_post(conn, %{"family" => family}) do
    person = Guardian.Plug.current_resource(conn)

    case Family.insert(family) do
      {:ok, family} ->
        Person.update(person, %{family_id: family.id})
        redirect(conn, to: "/")

      {:error, changeset} ->
        action = Routes.app_path(conn, :add_family_post)
        render(conn, "add_family.html", changeset: changeset, action: action)
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

  def register(conn, _) do
    changeset = Person.changeset(%Person{}, %{})
    render(conn, "register.html", changeset: changeset, action: Routes.app_path(conn, :register))
  end

  def register_post(conn, %{"person" => person}) do
    case Person.insert(person) do
      {:ok, person} ->
        conn
        |> Guardian.Plug.remember_me(person)
        |> redirect(to: "/")

      {:error, changeset} ->
        render(conn, "register.html",
          changeset: changeset,
          action: Routes.app_path(conn, :register)
        )
    end
  end

  def settings(conn, _) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)
    %{name: fam_name} = Family.get_by(%{id: family_id})

    fam_members = Person.list(%{family_id: family_id})
    render(conn, "settings.html", fam_members: fam_members, fam_name: fam_name)
  end
end
