defmodule Explore.Game.Combat.Damage do
  @moduledoc """
  Damage calculation and application.

  Handles damage types, resistances, weaknesses, and AOE calculations.
  """

  alias Explore.Game.Entities.Enemy

  @type damage_type :: :physical | :fire | :ice | :lightning | :poison

  @damage_types [:physical, :fire, :ice, :lightning, :poison]

  @doc """
  Gets all valid damage types.
  """
  @spec damage_types() :: list(damage_type())
  def damage_types, do: @damage_types

  @doc """
  Calculates the actual damage dealt to an enemy, accounting for resistances and weaknesses.
  """
  @spec calculate_damage(number(), damage_type(), Enemy.t()) :: number()
  def calculate_damage(base_damage, damage_type, %Enemy{} = enemy) do
    resistance = Map.get(enemy.resistances, damage_type, 0.0)
    weakness = Map.get(enemy.weaknesses, damage_type, 0.0)

    # Resistance reduces damage (0.3 = 30% reduction)
    # Weakness increases damage (0.5 = 50% increase)
    modifier = 1.0 - resistance + weakness

    max(0, base_damage * modifier)
  end

  @doc """
  Applies damage to an enemy and returns the updated enemy and actual damage dealt.
  """
  @spec apply_damage(Enemy.t(), number(), damage_type()) :: {Enemy.t(), number()}
  def apply_damage(%Enemy{} = enemy, base_damage, damage_type) do
    Enemy.take_damage(enemy, base_damage, damage_type)
  end

  @doc """
  Calculates AOE damage for enemies within the explosion radius.
  Damage falls off based on distance from the center.
  """
  @spec calculate_aoe_damage(
          number(),
          damage_type(),
          {number(), number()},
          number(),
          list(Enemy.t())
        ) :: list({String.t(), number()})
  def calculate_aoe_damage(base_damage, damage_type, center, radius, enemies) do
    enemies
    |> Enum.filter(fn enemy ->
      distance(enemy.position, center) <= radius
    end)
    |> Enum.map(fn enemy ->
      dist = distance(enemy.position, center)
      # Linear falloff from center
      falloff = 1.0 - dist / radius
      actual_damage = calculate_damage(base_damage * falloff, damage_type, enemy)
      {enemy.id, actual_damage}
    end)
  end

  @doc """
  Calculates chain lightning damage for multiple targets.
  Damage reduces with each chain.
  """
  @spec calculate_chain_damage(
          number(),
          damage_type(),
          list(Enemy.t()),
          non_neg_integer(),
          number()
        ) :: list({String.t(), number()})
  def calculate_chain_damage(base_damage, damage_type, enemies, max_chains, falloff) do
    enemies
    |> Enum.take(max_chains + 1)
    |> Enum.with_index()
    |> Enum.map(fn {enemy, index} ->
      chain_damage = base_damage * :math.pow(falloff, index)
      actual_damage = calculate_damage(chain_damage, damage_type, enemy)
      {enemy.id, actual_damage}
    end)
  end

  @doc """
  Gets the color associated with a damage type (for visual effects).
  """
  @spec damage_type_color(damage_type()) :: String.t()
  def damage_type_color(:physical), do: "#94a3b8"
  def damage_type_color(:fire), do: "#f97316"
  def damage_type_color(:ice), do: "#38bdf8"
  def damage_type_color(:lightning), do: "#facc15"
  def damage_type_color(:poison), do: "#22c55e"
  def damage_type_color(:energy), do: "#e879f9"
  def damage_type_color(_), do: "#ffffff"

  defp distance({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    :math.sqrt(dx * dx + dy * dy)
  end
end
