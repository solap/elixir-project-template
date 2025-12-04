defmodule Explore.Game.Combat.Targeting do
  @moduledoc """
  Target selection strategies for towers.

  Strategies determine which enemy a tower should target.
  """

  alias Explore.Game.Entities.{Tower, Enemy}

  @type strategy :: :first | :last | :closest | :strongest | :weakest

  @strategies [:first, :last, :closest, :strongest, :weakest]

  @doc """
  Gets all available targeting strategies.
  """
  @spec strategies() :: list(strategy())
  def strategies, do: @strategies

  @doc """
  Finds the best target for a tower based on its targeting strategy.
  Returns the enemy ID or nil if no valid targets.
  """
  @spec find_target(Tower.t(), %{String.t() => Enemy.t()}, strategy()) :: String.t() | nil
  def find_target(%Tower{} = tower, enemies, strategy) when is_map(enemies) do
    enemies_in_range = get_enemies_in_range(tower, enemies)

    if Enum.empty?(enemies_in_range) do
      nil
    else
      select_target(enemies_in_range, tower, strategy)
    end
  end

  @doc """
  Gets all enemies within a tower's range.
  """
  @spec get_enemies_in_range(Tower.t(), %{String.t() => Enemy.t()}) :: list(Enemy.t())
  def get_enemies_in_range(%Tower{} = tower, enemies) when is_map(enemies) do
    enemies
    |> Map.values()
    |> Enum.filter(fn enemy ->
      not Enemy.dead?(enemy) and Tower.in_range?(tower, enemy.position)
    end)
  end

  @doc """
  Gets enemies within a radius of a position.
  """
  @spec get_enemies_in_radius(
          {number(), number()},
          number(),
          %{String.t() => Enemy.t()}
        ) :: list(Enemy.t())
  def get_enemies_in_radius(position, radius, enemies) when is_map(enemies) do
    enemies
    |> Map.values()
    |> Enum.filter(fn enemy ->
      not Enemy.dead?(enemy) and distance(position, enemy.position) <= radius
    end)
  end

  @doc """
  Finds the closest enemy to a position.
  """
  @spec find_closest_enemy({number(), number()}, %{String.t() => Enemy.t()}) :: Enemy.t() | nil
  def find_closest_enemy(position, enemies) when is_map(enemies) do
    enemies
    |> Map.values()
    |> Enum.filter(fn enemy -> not Enemy.dead?(enemy) end)
    |> Enum.min_by(fn enemy -> distance(position, enemy.position) end, fn -> nil end)
  end

  # Private functions

  defp select_target(enemies, _tower, :first) do
    # Enemy furthest along the path
    enemy =
      enemies
      |> Enum.max_by(fn e -> e.path_progress end, fn -> nil end)

    if enemy, do: enemy.id, else: nil
  end

  defp select_target(enemies, _tower, :last) do
    # Enemy closest to spawn
    enemy =
      enemies
      |> Enum.min_by(fn e -> e.path_progress end, fn -> nil end)

    if enemy, do: enemy.id, else: nil
  end

  defp select_target(enemies, tower, :closest) do
    # Enemy nearest to tower
    enemy =
      enemies
      |> Enum.min_by(fn e -> Tower.distance_to(tower, e.position) end, fn -> nil end)

    if enemy, do: enemy.id, else: nil
  end

  defp select_target(enemies, _tower, :strongest) do
    # Enemy with highest current health
    enemy =
      enemies
      |> Enum.max_by(fn e -> e.health end, fn -> nil end)

    if enemy, do: enemy.id, else: nil
  end

  defp select_target(enemies, _tower, :weakest) do
    # Enemy with lowest current health
    enemy =
      enemies
      |> Enum.min_by(fn e -> e.health end, fn -> nil end)

    if enemy, do: enemy.id, else: nil
  end

  defp select_target(enemies, tower, _unknown) do
    # Default to first
    select_target(enemies, tower, :first)
  end

  defp distance({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    :math.sqrt(dx * dx + dy * dy)
  end
end
