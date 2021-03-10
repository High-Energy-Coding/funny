defmodule Funny.IEXing do
  alias Funny.Catalog.Person

  def stuff do
    vm_fam_id = "c51628bd-8d2c-487e-ae00-79c1517b5384"

    [
      {"Jeff", "jeffers", "1234"},
      {"Kristen", "kristen", "1234"},
      {"Midnight", nil, nil},
      {"Tucker", nil, nil}
    ]
    |> Enum.each(fn {n, u, p} ->
      Person.insert(%{name: n, username: u, password: p, family_id: vm_fam_id})
    end)
  end
end
