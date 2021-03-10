import Config

IO.inspect("""
  DB_USER
 #{System.fetch_env!("DB_USER")}
  DB_PASSWORD
 #{System.fetch_env!("DB_PASSWORD")}
  DB_NAME
 #{System.fetch_env!("DB_NAME")}
  DB_HOST
 #{System.fetch_env!("DB_HOST")}
  DB_PORT
 #{System.fetch_env!("DB_PORT")}
""")

config :funny, Funny.Repo,
  username: System.fetch_env!("DB_USER"),
  password: System.fetch_env!("DB_PASSWORD"),
  database: System.fetch_env!("DB_NAME"),
  hostname: System.fetch_env!("DB_HOST"),
  port: System.fetch_env!("DB_PORT"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 5,
  ssl: System.get_env("ENABLE_DATABASE_SSL", "true") == "true"

config :funny, FunnyWeb.Endpoint,
  url: [host: "funny.highenergycoding.com", port: 80],
  server: true,
  http: [
    :inet6,
    port: "80"
  ]
