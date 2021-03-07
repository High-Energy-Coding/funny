defmodule FunnyWeb.PersonController do
  use FunnyWeb, :controller

  alias Funny.Catalog
  alias Funny.Context
  alias Funny.Catalog.Person

  action_fallback FunnyWeb.FallbackController

  def index(conn, _params) do
    %Person{family_id: family_id} = Guardian.Plug.current_resource(conn)

    case Catalog.list_persons(%{family_id: family_id}, %Context{}) do
      {:ok, persons} -> render(conn, "index.json", persons: persons)
    end
  end
end
