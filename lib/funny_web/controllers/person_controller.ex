defmodule FunnyWeb.PersonController do
  use FunnyWeb, :controller

  alias Funny.Catalog
  alias Funny.Context

  action_fallback FunnyWeb.FallbackController

  def index(conn, _params) do
    case Catalog.list_persons(%{}, %Context{}) do
      {:ok, persons} -> render(conn, "index.json", persons: persons)
    end
  end
end
