import Config

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
  url: [host: System.get_env("ENDPOINT_HOST", "funny.highenergycoding.com"), port: 80],
  server: true,
  http: [
    :inet6,
    port: "80"
  ]

config :argon2_elixir,
  t_cost: 2,
  m_cost: 8

config :funny, :aws_adapter, Funny.AWS.Default
config :funny, :s3_bucket, "high-energy-funny"
