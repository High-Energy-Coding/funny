# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :funny,
  ecto_repos: [Funny.Repo]

config :funny, Funny.Repo, migration_primary_key: [name: :id, type: :binary_id]

# Configures the endpoint
config :funny, FunnyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SVL82aUNkoVuIG9VToMZxc+cWQUDfGNlVHfEUTbeRn8Z4lMAZOkSUvRh9stDPCVZ",
  render_errors: [view: FunnyWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Funny.PubSub,
  live_view: [signing_salt: "LNW6AT6M"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Tell material about Repo
config :material, repo: Funny.Repo

config :funny, Funny.Accounts.Guardian,
  issuer: "funny",
  secret_key: "g++gf/rmFG+z9cc3PXa8dPfJ001v2zU3skXLu5yr2YHNFF5RXWcZgsIKYzT72Jvp",
  ttl: {52, :weeks}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
