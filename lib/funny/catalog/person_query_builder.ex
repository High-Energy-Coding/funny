defmodule Funny.Catalog.PersonQueryBuilder do
  use Material.QueryBuilder

  import Ecto.Query, only: [from: 2, has_named_binding?: 2]

  #  def build_query(query, :family_id, _fam_id, context) do
  #    query
  #  end
end
