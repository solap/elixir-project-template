defmodule Explore.Game.Map.Grid do
  @moduledoc """
  Grid-based placement system for towers.

  The grid divides the game area into cells where towers can be placed.
  Cells occupied by the path or already containing towers are blocked.
  """

  @type cell_state :: :empty | :path | :tower | :blocked

  @type t :: %__MODULE__{
          width: non_neg_integer(),
          height: non_neg_integer(),
          cell_size: number(),
          cells: %{{non_neg_integer(), non_neg_integer()} => cell_state()}
        }

  defstruct width: 20,
            height: 15,
            cell_size: 40,
            cells: %{}

  @doc """
  Creates a new grid with the given dimensions.
  """
  @spec new(non_neg_integer(), non_neg_integer(), number()) :: t()
  def new(width, height, cell_size \\ 40) do
    %__MODULE__{
      width: width,
      height: height,
      cell_size: cell_size,
      cells: %{}
    }
  end

  @doc """
  Creates a grid from a map configuration.
  """
  @spec from_config(map()) :: t()
  def from_config(config) do
    map_width = Map.get(config, :width, 800)
    map_height = Map.get(config, :height, 600)
    cell_size = Map.get(config, :grid_size, 40)

    grid_width = div(map_width, cell_size)
    grid_height = div(map_height, cell_size)

    grid = new(grid_width, grid_height, cell_size)

    # Mark path cells as blocked
    path = Map.get(config, :path, [])
    path_width = Map.get(config, :path_width, 30)

    mark_path_cells(grid, path, path_width)
  end

  @doc """
  Checks if a tower can be placed at the given grid position.
  """
  @spec can_place_tower?(t(), {non_neg_integer(), non_neg_integer()}) :: boolean()
  def can_place_tower?(%__MODULE__{} = grid, {x, y}) do
    in_bounds?(grid, {x, y}) and get_cell(grid, {x, y}) == :empty
  end

  @doc """
  Checks if a world position is valid for tower placement.
  """
  @spec can_place_at_world_position?(t(), {number(), number()}) :: boolean()
  def can_place_at_world_position?(%__MODULE__{} = grid, {wx, wy}) do
    grid_pos = world_to_grid(grid, {wx, wy})
    can_place_tower?(grid, grid_pos)
  end

  @doc """
  Places a tower at the given grid position.
  Returns {:ok, updated_grid} or {:error, reason}.
  """
  @spec place_tower(t(), {non_neg_integer(), non_neg_integer()}) ::
          {:ok, t()} | {:error, atom()}
  def place_tower(%__MODULE__{} = grid, pos) do
    if can_place_tower?(grid, pos) do
      {:ok, set_cell(grid, pos, :tower)}
    else
      {:error, :invalid_position}
    end
  end

  @doc """
  Removes a tower from the given grid position.
  """
  @spec remove_tower(t(), {non_neg_integer(), non_neg_integer()}) :: t()
  def remove_tower(%__MODULE__{} = grid, pos) do
    if get_cell(grid, pos) == :tower do
      set_cell(grid, pos, :empty)
    else
      grid
    end
  end

  @doc """
  Gets the state of a cell.
  """
  @spec get_cell(t(), {non_neg_integer(), non_neg_integer()}) :: cell_state()
  def get_cell(%__MODULE__{cells: cells}, pos) do
    Map.get(cells, pos, :empty)
  end

  @doc """
  Sets the state of a cell.
  """
  @spec set_cell(t(), {non_neg_integer(), non_neg_integer()}, cell_state()) :: t()
  def set_cell(%__MODULE__{} = grid, pos, state) do
    %{grid | cells: Map.put(grid.cells, pos, state)}
  end

  @doc """
  Converts a grid position to world coordinates (center of cell).
  """
  @spec grid_to_world(t(), {non_neg_integer(), non_neg_integer()}) :: {number(), number()}
  def grid_to_world(%__MODULE__{cell_size: size}, {gx, gy}) do
    {gx * size + size / 2, gy * size + size / 2}
  end

  @doc """
  Converts world coordinates to a grid position.
  """
  @spec world_to_grid(t(), {number(), number()}) :: {non_neg_integer(), non_neg_integer()}
  def world_to_grid(%__MODULE__{cell_size: size}, {wx, wy}) do
    {trunc(wx / size), trunc(wy / size)}
  end

  @doc """
  Checks if a grid position is within bounds.
  """
  @spec in_bounds?(t(), {non_neg_integer(), non_neg_integer()}) :: boolean()
  def in_bounds?(%__MODULE__{width: w, height: h}, {x, y}) do
    x >= 0 and x < w and y >= 0 and y < h
  end

  @doc """
  Gets all valid (empty) positions for tower placement.
  """
  @spec valid_positions(t()) :: list({non_neg_integer(), non_neg_integer()})
  def valid_positions(%__MODULE__{} = grid) do
    for x <- 0..(grid.width - 1),
        y <- 0..(grid.height - 1),
        can_place_tower?(grid, {x, y}),
        do: {x, y}
  end

  @doc """
  Gets the dimensions of the grid in world coordinates.
  """
  @spec world_dimensions(t()) :: {number(), number()}
  def world_dimensions(%__MODULE__{width: w, height: h, cell_size: size}) do
    {w * size, h * size}
  end

  # Mark cells that the path passes through as blocked
  defp mark_path_cells(grid, path_waypoints, path_width) do
    half_width = path_width / 2

    Enum.reduce(path_waypoints, grid, fn waypoint, acc_grid ->
      {wx, wy} = normalize_waypoint(waypoint)

      # Mark cells around this waypoint
      for dx <- -1..1,
          dy <- -1..1,
          reduce: acc_grid do
        g ->
          check_x = wx + dx * half_width
          check_y = wy + dy * half_width
          {gx, gy} = world_to_grid(g, {check_x, check_y})

          if in_bounds?(g, {gx, gy}) and get_cell(g, {gx, gy}) == :empty do
            set_cell(g, {gx, gy}, :path)
          else
            g
          end
      end
    end)
  end

  defp normalize_waypoint({x, y}), do: {x, y}
  defp normalize_waypoint(%{x: x, y: y}), do: {x, y}
  defp normalize_waypoint(%{"x" => x, "y" => y}), do: {x, y}
end
