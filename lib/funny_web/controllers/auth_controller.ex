defmodule FunnyWeb.AuthController do
  use FunnyWeb, :controller

  alias Funny.Accounts

  alias Funny.Accounts.Guardian

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
    |> put_status(200)
    |> json(%{})
  end
end