defmodule Funny.Catalog.JokeQueryBuilder do
  use Material.QueryBuilder

  import Ecto.Query, only: [from: 2, has_named_binding?: 2, preload: 3]

  alias Ecto.Query
  alias Ecto.Queryable

  def build_query(query, :with_person, true, _context) do
    query = ensure_person_joined(query)

    from(query, preload: [:person])
  end

  defp ensure_person_joined(query) do
    if has_named_binding?(query, :person) do
      query
    else
      from(j in query, join: p in assoc(j, :person))
    end
  end
end
