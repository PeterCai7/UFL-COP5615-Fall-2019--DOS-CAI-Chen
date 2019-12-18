defmodule Proj4p2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    IO.inspect _args
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      # Proj4p2.Repo,
      # Start the endpoint when the application starts
      supervisor(Proj4p2Web.Endpoint, []),
      # Proj4p2Web.Endpoint
      # Starts a worker by calling: Proj4p2.Worker.start_link(arg)

      # {Proj4p2.Worker, arg},
    ]
    arg=["server","200"]
    Proj4p2.LibFunctions.get_ip_address(arg)|>Proj4p2.Boss.start_boss

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proj4p2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Proj4p2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end