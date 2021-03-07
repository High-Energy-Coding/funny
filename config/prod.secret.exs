# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

config :funny, Funny.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: nil,
  database: nil,
  ssl: true,
  pool_size: nil

secret_key_base = "tqiBNMwo8yv0OPNx1hmlXUDuH6wGYEIrwSU7UB7t8nAyutAn8qBJ4y6HUC81AVzN"

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :funny, FunnyWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
