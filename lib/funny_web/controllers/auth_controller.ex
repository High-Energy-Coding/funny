defmodule FunnyWeb.AuthController do
  use FunnyWeb, :controller

  alias Funny.Accounts

  alias Funny.Accounts.Guardian

  def register(conn, attrs) do
    IO.inspect(attrs, label: "incoming attrs")

    Accounts.register_person(attrs)
    |> case do
      {:ok, person} ->
        conn
        |> Guardian.Plug.remember_me(person)
        |> put_view(FunnyWeb.PersonView)
        |> render("show.json", person: person)

      {:error, reason} ->
        conn
        |> put_status(401)
        |> json(%{poopy: "#{inspect(reason)}"})
    end
  end

  def login(conn, %{"username" => username, "password" => password}) do
    Accounts.authenticate_person(username, password)
    |> case do
      {:ok, person} ->
        conn
        |> Guardian.Plug.remember_me(person)
        |> put_view(FunnyWeb.PersonView)
        |> render("show.json", person: person)

      {:error, reason} ->
        conn
        |> put_status(401)
        |> json(%{poopy: "#{inspect(reason)}"})
    end
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out(clear_remember_me: true)
    |> redirect(to: "/sign_in")
  end
end
