defmodule AiGuard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AiGuardWeb.Telemetry,
      AiGuard.Repo,
      {DNSCluster, query: Application.get_env(:ai_guard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AiGuard.PubSub},
      # Start a worker by calling: AiGuard.Worker.start_link(arg)
      # {AiGuard.Worker, arg},
      # Start to serve requests, typically the last entry
      AiGuardWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AiGuard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AiGuardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
