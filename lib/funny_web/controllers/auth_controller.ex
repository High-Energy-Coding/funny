defmodule FunnyWeb.AuthController do
  use FunnyWeb, :controller

  alias Funny.Accounts.Guardian

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out(clear_remember_me: true)
    |> redirect(to: "/login")
  end
end
