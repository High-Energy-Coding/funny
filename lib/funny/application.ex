defmodule Funny.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Funny.Repo,
      # Start the Telemetry supervisor
      FunnyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Funny.PubSub},
      # Start the Endpoint (http/https)
      FunnyWeb.Endpoint
      # Start a worker by calling: Funny.Worker.start_link(arg)
      # {Funny.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Funny.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FunnyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
