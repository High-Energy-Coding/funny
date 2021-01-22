defmodule Funny.Repo do
  use Ecto.Repo,
    otp_app: :funny,
    adapter: Ecto.Adapters.Postgres
end
