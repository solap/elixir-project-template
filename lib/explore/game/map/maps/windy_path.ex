defmodule Explore.Game.Map.Maps.WindyPath do
  @moduledoc """
  The first map: a winding path from left to right.

  This module provides a hardcoded fallback for the windy path map.
  The map can also be loaded from YAML configuration.
  """

  alias Explore.Game.Map.GameMap

  @doc """
  Creates the Windy Path map.
  """
  @spec create() :: GameMap.t()
  def create do
    GameMap.new(config())
  end

  @doc """
  Gets the raw configuration for this map.
  """
  @spec config() :: map()
  def config do
    %{
      map: %{
        name: "The Winding Path",
        width: 800,
        height: 600,
        grid_size: 40,
        path_width: 30,
        path: [
          %{x: 0, y: 300},
          %{x: 100, y: 300},
          %{x: 150, y: 200},
          %{x: 250, y: 100},
          %{x: 400, y: 100},
          %{x: 500, y: 200},
          %{x: 550, y: 350},
          %{x: 500, y: 500},
          %{x: 350, y: 500},
          %{x: 250, y: 400},
          %{x: 300, y: 300},
          %{x: 450, y: 250},
          %{x: 600, y: 300},
          %{x: 700, y: 350},
          %{x: 800, y: 300}
        ]
      }
    }
  end
end
