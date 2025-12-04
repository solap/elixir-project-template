defmodule Explore.Game.Entities.Enemy do
  @moduledoc """
  Enemy entity representing a creature walking along the path.

  Enemies:
  - Move along the path from start to end
  - Have health and can take damage
  - Have resistances to damage types
  - Can have status effects applied
  - Grant rewards when killed
  """

  alias Explore.Game.Combat.Effects.Effect

  @type position :: {number(), number()}
  @type damage_type :: :physical | :fire | :ice | :lightning | :poison

  @type special :: %{
          split_on_death: map() | nil,
          regenerate: map() | nil,
          flying: boolean() | nil
        }

  @type t :: %__MODULE__{
          id: String.t(),
          type: atom(),
          name: String.t(),
          position: position(),
          health: number(),
          max_health: number(),
          speed: number(),
          base_speed: number(),
          path_progress: number(),
          reward: non_neg_integer(),
          resistances: %{damage_type() => number()},
          weaknesses: %{damage_type() => number()},
          effects: list(Effect.t()),
          special: special() | nil
        }

  defstruct id: nil,
            type: nil,
            name: "",
            position: {0, 0},
            health: 100,
            max_health: 100,
            speed: 50,
            base_speed: 50,
            path_progress: 0.0,
            reward: 10,
            resistances: %{},
            weaknesses: %{},
            effects: [],
            special: nil

  @doc """
  Creates a new enemy with the given type and config.
  """
  @spec new(atom(), map()) :: t()
  def new(type, config \\ %{}) do
    id = generate_id()
    health = Map.get(config, :health, 100)
    speed = Map.get(config, :speed, 50)

    %__MODULE__{
      id: id,
      type: type,
      name: Map.get(config, :name, to_string(type)),
      health: health,
      max_health: health,
      speed: speed,
      base_speed: speed,
      reward: Map.get(config, :reward, 10),
      resistances: Map.get(config, :resistances, %{}),
      weaknesses: Map.get(config, :weaknesses, %{}),
      special: Map.get(config, :special)
    }
  end

  @doc """
  Moves the enemy along the path by the given delta time.
  Returns the updated enemy and whether it reached the end.
  """
  @spec move(t(), number(), number()) :: {t(), boolean()}
  def move(%__MODULE__{} = enemy, delta, path_length) do
    distance = enemy.speed * delta
    progress_delta = distance / path_length
    new_progress = enemy.path_progress + progress_delta

    reached_end = new_progress >= 1.0

    {%{enemy | path_progress: min(1.0, new_progress)}, reached_end}
  end

  @doc """
  Updates the enemy's position based on the path progress.
  """
  @spec set_position(t(), position()) :: t()
  def set_position(%__MODULE__{} = enemy, position) do
    %{enemy | position: position}
  end

  @doc """
  Applies damage to the enemy, accounting for resistances and weaknesses.
  Returns the updated enemy and the actual damage dealt.
  """
  @spec take_damage(t(), number(), damage_type()) :: {t(), number()}
  def take_damage(%__MODULE__{} = enemy, amount, damage_type) do
    resistance = Map.get(enemy.resistances, damage_type, 0.0)
    weakness = Map.get(enemy.weaknesses, damage_type, 0.0)

    # Resistance reduces damage, weakness increases it
    modifier = 1.0 - resistance + weakness
    actual_damage = max(0, amount * modifier)

    new_health = max(0, enemy.health - actual_damage)

    {%{enemy | health: new_health}, actual_damage}
  end

  @doc """
  Checks if the enemy is dead (health <= 0).
  """
  @spec dead?(t()) :: boolean()
  def dead?(%__MODULE__{health: health}) do
    health <= 0
  end

  @doc """
  Gets the health percentage (0.0 to 1.0).
  """
  @spec health_percentage(t()) :: number()
  def health_percentage(%__MODULE__{health: health, max_health: max_health}) do
    if max_health > 0, do: health / max_health, else: 0.0
  end

  @doc """
  Applies an effect to the enemy.
  """
  @spec apply_effect(t(), Effect.t()) :: t()
  def apply_effect(%__MODULE__{effects: effects} = enemy, effect) do
    # Check if same effect type already exists, update duration if so
    existing_index = Enum.find_index(effects, fn e -> e.type == effect.type end)

    new_effects =
      if existing_index do
        List.update_at(effects, existing_index, fn existing ->
          # Keep the longer duration and stronger effect
          %{
            existing
            | duration: max(existing.duration, effect.duration),
              strength: max(Map.get(existing, :strength, 0), Map.get(effect, :strength, 0))
          }
        end)
      else
        [effect | effects]
      end

    %{enemy | effects: new_effects}
  end

  @doc """
  Updates all effects on the enemy, reducing durations and applying tick damage.
  Returns the updated enemy.
  """
  @spec tick_effects(t(), number()) :: t()
  def tick_effects(%__MODULE__{effects: effects} = enemy, delta_ms) do
    {remaining_effects, total_tick_damage} =
      Enum.reduce(effects, {[], 0}, fn effect, {acc, damage} ->
        new_duration = effect.duration - delta_ms

        if new_duration > 0 do
          # Handle nil damage_per_tick (e.g., for slow effects)
          damage_per_tick = effect.damage_per_tick || 0
          tick_damage = damage_per_tick * (delta_ms / 1000)
          {[%{effect | duration: new_duration} | acc], damage + tick_damage}
        else
          {acc, damage}
        end
      end)

    new_health = max(0, enemy.health - total_tick_damage)
    speed_modifier = calculate_speed_modifier(remaining_effects)

    %{
      enemy
      | effects: remaining_effects,
        health: new_health,
        speed: enemy.base_speed * speed_modifier
    }
  end

  @doc """
  Removes all effects from the enemy.
  """
  @spec clear_effects(t()) :: t()
  def clear_effects(%__MODULE__{} = enemy) do
    %{enemy | effects: [], speed: enemy.base_speed}
  end

  @doc """
  Checks if the enemy has a specific effect type.
  """
  @spec has_effect?(t(), atom()) :: boolean()
  def has_effect?(%__MODULE__{effects: effects}, effect_type) do
    Enum.any?(effects, fn e -> e.type == effect_type end)
  end

  @doc """
  Checks if the enemy splits on death.
  """
  @spec splits_on_death?(t()) :: boolean()
  def splits_on_death?(%__MODULE__{special: special}) do
    special != nil and Map.has_key?(special, :split_on_death)
  end

  @doc """
  Gets the split configuration if the enemy splits on death.
  """
  @spec get_split_config(t()) :: map() | nil
  def get_split_config(%__MODULE__{special: special}) do
    if special, do: Map.get(special, :split_on_death)
  end

  @doc """
  Checks if the enemy regenerates health.
  """
  @spec regenerates?(t()) :: boolean()
  def regenerates?(%__MODULE__{special: special}) do
    special != nil and Map.has_key?(special, :regenerate)
  end

  @doc """
  Applies regeneration if applicable.
  """
  @spec apply_regeneration(t(), number()) :: t()
  def apply_regeneration(%__MODULE__{} = enemy, delta_ms) do
    if regenerates?(enemy) do
      regen_config = Map.get(enemy.special, :regenerate, %{})
      amount = Map.get(regen_config, :amount, 0)
      interval = Map.get(regen_config, :interval, 1000)

      heal_amount = amount * (delta_ms / interval)
      new_health = min(enemy.max_health, enemy.health + heal_amount)

      %{enemy | health: new_health}
    else
      enemy
    end
  end

  @doc """
  Checks if the enemy is flying.
  """
  @spec flying?(t()) :: boolean()
  def flying?(%__MODULE__{special: special}) do
    special != nil and Map.get(special, :flying, false)
  end

  # Calculate speed modifier from active effects
  defp calculate_speed_modifier(effects) do
    # Check for freeze or stun first (complete stop)
    has_freeze = Enum.any?(effects, fn e -> e.type in [:freeze, :stun] end)

    if has_freeze do
      0.0
    else
      # Find slow effects
      slow_effects = Enum.filter(effects, fn e -> e.type == :slow end)

      if Enum.empty?(slow_effects) do
        1.0
      else
        # Take the strongest slow (lowest multiplier)
        # Use struct field access and handle nil
        slow_effects
        |> Enum.map(fn e -> e.strength || 1.0 end)
        |> Enum.min()
      end
    end
  end

  defp generate_id do
    "enemy_#{:erlang.unique_integer([:positive])}"
  end
end
