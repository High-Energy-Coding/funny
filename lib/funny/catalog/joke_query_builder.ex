defmodule Funny.Catalog.JokeQueryBuilder do
  use Material.QueryBuilder

  import Ecto.Query, only: [from: 2, has_named_binding?: 2]

  def build_query(query, :latest_first, true, _context) do
    from(j in query, order_by: [desc: j.inserted_at])
  end

  def build_query(query, :with_person, true, _context) do
    query = ensure_person_joined(query)

    from(query, preload: [:person])
  end

  def build_query(query, :with_comments, true, _context) do
    from(query, preload: [:comments])
  end

  def build_query(query, :family_id, family_id, _context) do
    query =
      query
      |> ensure_assoc_joined(:family)

    from([q, family: f] in query,
      where: f.id == ^family_id,
      preload: [:person]
    )
  end

  defp ensure_person_joined(query) do
    if has_named_binding?(query, :person) do
      query
    else
      from(j in query, join: p in assoc(j, :person))
    end
  end

  defp ensure_assoc_joined(query, :person) do
    query
    |> ensure_has_binding(:person, fn q ->
      from(j in q, left_join: p in assoc(j, :person), as: :person)
    end)
  end

  defp ensure_assoc_joined(query, :family) do
    query
    |> ensure_assoc_joined(:person)
    |> ensure_has_binding(:family, fn q ->
      from([person: p] in q, left_join: f in assoc(p, :family), as: :family)
    end)
  end

  defp ensure_has_binding(query, binding_name, bind_fn) when is_function(bind_fn, 1) do
    if has_named_binding?(query, binding_name) do
      query
    else
      bind_fn.(query)
    end
  end
end
