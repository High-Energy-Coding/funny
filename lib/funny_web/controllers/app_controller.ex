defmodule FunnyWeb.AppController do
  use FunnyWeb, :controller
  alias Funny.Catalog.Person
  alias Funny.Catalog.Login
  alias Funny.Catalog.Family
  alias Funny.Catalog.ChangePassword

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

  def add_family_member(conn, _) do
    %Person{family_id: family_id} = person = Guardian.Plug.current_resource(conn)

    %{name: fam_name} = Family.get_by(%{id: family_id})
    changeset = Person.changeset(%Person{}, %{family_id: person.family_id})

    render(conn, "add_family_member.html",
      changeset: changeset,
      action: Routes.app_path(conn, :add_family_member_post),
      fam_name: fam_name
    )
  end

  def add_family_member_post(conn, %{"person" => new_member}) do
    %Person{family_id: family_id} = person = Guardian.Plug.current_resource(conn)
    %{name: fam_name} = Family.get_by(%{id: family_id})

    case Person.insert(%{family_id: family_id, name: new_member["name"]}) do
      {:ok, _} ->
        redirect(conn, to: "/settings")

      {:error, changeset} ->
        IO.inspect(changeset)

        render(conn, "add_family_member.html",
          changeset: changeset,
          action: Routes.app_path(conn, :add_family_member_post),
          fam_name: fam_name
        )
    end
  end

  def sign_in(conn, _something) do
    changeset = Login.changeset(%Login{}, %{})

    render(conn, "sign_in.html",
      changeset: changeset,
      action: Routes.app_path(conn, :login),
      invalid_login: false
    )
  end

  def login(conn, %{"login" => %{"email" => email, "password" => password} = params}) do
    changeset = Login.changeset(%Login{}, params)
    decision = Ecto.Changeset.apply_action(changeset, :checkeroonies)

    case decision do
      {:ok, _} ->
        case Accounts.authenticate_person(email, password) do
          {:ok, login} ->
            conn
            |> Guardian.Plug.remember_me(login)
            |> redirect(to: "/")

          _ ->
            conn
            |> assign(:invalid_login, true)
            |> render("sign_in.html", changeset: changeset, action: Routes.app_path(conn, :login))
        end

      {:error, error_cs} ->
        conn
        |> assign(:invalid_login, false)
        |> render("sign_in.html", changeset: error_cs, action: Routes.app_path(conn, :login))
    end
  end

  def register(conn, _) do
    changeset = Person.new_register_changeset(%Person{}, %{})
    render(conn, "register.html", changeset: changeset, action: Routes.app_path(conn, :register))
  end

  def register_post(conn, %{"person" => person}) do
    changeset = Person.new_register_changeset(%Person{}, person)

    case Funny.Repo.insert(changeset) do
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

  def forgot_password(conn, _) do
    render(conn, "forgot_password.html")
  end

  def email_new_password(conn, %{"email" => email}) do
    Accounts.email_new_password(email)

    conn
    |> put_flash(:info, "Welcome to Phoenix, from flash info!")
    |> render("forgot_password.html")
  end

  def change_password(conn, _) do
    changeset = ChangePassword.changeset(%ChangePassword{}, %{})
    action = Routes.app_path(conn, :post_change_password)

    render(conn, "change_password.html",
      changeset: changeset,
      action: action,
      invalid_login: false
    )
  end

  def post_change_password(conn, %{"change_password" => params}) do
    person = Guardian.Plug.current_resource(conn)
    changeset = ChangePassword.changeset(%ChangePassword{}, params)
    decision = Ecto.Changeset.apply_action(changeset, :checkeroonies)

    case decision do
      {:ok, change_password} ->
        case Accounts.authenticate_person(person.email, change_password.old_password) do
          {:ok, _} ->
            Person.update(person, %{password: change_password.new_password})

            conn
            |> redirect(to: "/")

          _ ->
            conn
            |> assign(:invalid_login, true)
            |> render("change_password.html",
              changeset: changeset,
              action: Routes.app_path(conn, :post_change_password),
              invalid_login: true
            )
        end

      {:error, error_changeset} ->
        action = Routes.app_path(conn, :post_change_password)

        render(conn, "change_password.html",
          changeset: error_changeset,
          action: action,
          invalid_login: false
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
