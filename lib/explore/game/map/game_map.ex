defmodule Explore.Game.Map.GameMap do
  @moduledoc """
  Represents a complete game map with path and grid.
  """

  alias Explore.Game.Map.{Path, Grid}

  @type t :: %__MODULE__{
          name: String.t(),
          width: number(),
          height: number(),
          path: Path.t(),
          grid: Grid.t(),
          path_width: number()
        }

  defstruct name: "Unknown Map",
            width: 800,
            height: 600,
            path: nil,
            grid: nil,
            path_width: 30

  @doc """
  Creates a new game map from a configuration.
  """
  @spec new(map()) :: t()
  def new(config) do
    map_config = Map.get(config, :map, config)

    name = Map.get(map_config, :name, "Unknown Map")
    width = Map.get(map_config, :width, 800)
    height = Map.get(map_config, :height, 600)
    path_width = Map.get(map_config, :path_width, 30)
    path_waypoints = Map.get(map_config, :path, [])

    path = Path.new(path_waypoints)
    grid = Grid.from_config(map_config)

    %__MODULE__{
      name: name,
      width: width,
      height: height,
      path: path,
      grid: grid,
      path_width: path_width
    }
  end

  @doc """
  Gets the position for an enemy at the given path progress.
  """
  @spec position_at_progress(t(), number()) :: {number(), number()}
  def position_at_progress(%__MODULE__{path: path}, progress) do
    Path.progress_to_position(path, progress)
  end

  @doc """
  Gets the total path length.
  """
  @spec path_length(t()) :: number()
  def path_length(%__MODULE__{path: path}) do
    Path.length(path)
  end

  @doc """
  Checks if a tower can be placed at the given world position.
  """
  @spec can_place_tower?(t(), {number(), number()}) :: boolean()
  def can_place_tower?(%__MODULE__{grid: grid}, world_pos) do
    Grid.can_place_at_world_position?(grid, world_pos)
  end

  @doc """
  Places a tower at the given world position.
  Returns {:ok, updated_map} or {:error, reason}.
  """
  @spec place_tower(t(), {number(), number()}) :: {:ok, t()} | {:error, atom()}
  def place_tower(%__MODULE__{grid: grid} = map, world_pos) do
    grid_pos = Grid.world_to_grid(grid, world_pos)

    case Grid.place_tower(grid, grid_pos) do
      {:ok, new_grid} -> {:ok, %{map | grid: new_grid}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Removes a tower from the given world position.
  """
  @spec remove_tower(t(), {number(), number()}) :: t()
  def remove_tower(%__MODULE__{grid: grid} = map, world_pos) do
    grid_pos = Grid.world_to_grid(grid, world_pos)
    new_grid = Grid.remove_tower(grid, grid_pos)
    %{map | grid: new_grid}
  end

  @doc """
  Snaps a world position to the center of the nearest grid cell.
  """
  @spec snap_to_grid(t(), {number(), number()}) :: {number(), number()}
  def snap_to_grid(%__MODULE__{grid: grid}, world_pos) do
    grid_pos = Grid.world_to_grid(grid, world_pos)
    Grid.grid_to_world(grid, grid_pos)
  end

  @doc """
  Gets all valid positions for tower placement as world coordinates.
  """
  @spec valid_tower_positions(t()) :: list({number(), number()})
  def valid_tower_positions(%__MODULE__{grid: grid}) do
    grid
    |> Grid.valid_positions()
    |> Enum.map(fn grid_pos -> Grid.grid_to_world(grid, grid_pos) end)
  end

  @doc """
  Gets the path start position.
  """
  @spec spawn_position(t()) :: {number(), number()}
  def spawn_position(%__MODULE__{path: path}) do
    Path.start_position(path)
  end

  @doc """
  Gets the path end position.
  """
  @spec exit_position(t()) :: {number(), number()}
  def exit_position(%__MODULE__{path: path}) do
    Path.end_position(path)
  end
end
