defmodule Explore.Application do
  @moduledoc """
  The Explore Application.

  Starts the supervision tree including the Phoenix endpoint
  and PubSub for game events.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ExploreWeb.Telemetry,
      {Phoenix.PubSub, name: Explore.PubSub},
      ExploreWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Explore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ExploreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
