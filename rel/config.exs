import Config

config :funny, Funny.Repo,
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  database: System.get_env("DB_NAME", "funny_dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  port: System.get_env("DB_PORT", "5432"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 5,
  ssl: System.get_env("ENABLE_DATABASE_SSL", "false") == "true"

config :funny, FunnyWeb.Endpoint,
  url: [host: "localhost", port: 4000],
  server: true,
  http: [
    :inet6,
    port: "4000"
  ]
