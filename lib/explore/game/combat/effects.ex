defmodule Explore.Game.Combat.Effects do
  @moduledoc """
  Status effects that can be applied to enemies.

  Effects include:
  - Slow: Reduces enemy movement speed
  - Burn: Deals damage over time (fire)
  - Poison: Deals damage over time (stacking)
  - Freeze: Stops enemy movement briefly
  - Stun: Stops enemy completely
  """

  defmodule Effect do
    @moduledoc """
    Struct representing a status effect on an enemy.
    """

    @type effect_type :: :slow | :burn | :poison | :freeze | :stun

    @type t :: %__MODULE__{
            type: effect_type(),
            duration: non_neg_integer(),
            strength: number() | nil,
            damage_per_tick: number() | nil,
            source_id: String.t() | nil
          }

    defstruct type: :slow,
              duration: 1000,
              strength: nil,
              damage_per_tick: nil,
              source_id: nil
  end

  @doc """
  Creates a slow effect.
  Strength is a multiplier (0.5 = 50% speed).
  """
  @spec slow(non_neg_integer(), number(), String.t() | nil) :: Effect.t()
  def slow(duration_ms, strength \\ 0.5, source_id \\ nil) do
    %Effect{
      type: :slow,
      duration: duration_ms,
      strength: strength,
      source_id: source_id
    }
  end

  @doc """
  Creates a burn effect (fire damage over time).
  """
  @spec burn(non_neg_integer(), number(), String.t() | nil) :: Effect.t()
  def burn(duration_ms, damage_per_second, source_id \\ nil) do
    %Effect{
      type: :burn,
      duration: duration_ms,
      damage_per_tick: damage_per_second,
      source_id: source_id
    }
  end

  @doc """
  Creates a poison effect (damage over time, can stack).
  """
  @spec poison(non_neg_integer(), number(), String.t() | nil) :: Effect.t()
  def poison(duration_ms, damage_per_second, source_id \\ nil) do
    %Effect{
      type: :poison,
      duration: duration_ms,
      damage_per_tick: damage_per_second,
      source_id: source_id
    }
  end

  @doc """
  Creates a freeze effect (complete stop).
  """
  @spec freeze(non_neg_integer(), String.t() | nil) :: Effect.t()
  def freeze(duration_ms, source_id \\ nil) do
    %Effect{
      type: :freeze,
      duration: duration_ms,
      strength: 0.0,
      source_id: source_id
    }
  end

  @doc """
  Creates a stun effect (complete stop, ignores immunity).
  """
  @spec stun(non_neg_integer(), String.t() | nil) :: Effect.t()
  def stun(duration_ms, source_id \\ nil) do
    %Effect{
      type: :stun,
      duration: duration_ms,
      strength: 0.0,
      source_id: source_id
    }
  end

  @doc """
  Creates an effect from a configuration map.
  """
  @spec from_config(map()) :: Effect.t()
  def from_config(config) do
    type = config |> Map.get(:type) |> to_atom()
    duration = Map.get(config, :duration, 1000)

    case type do
      :slow ->
        slow(duration, Map.get(config, :strength, 0.5))

      :burn ->
        burn(duration, Map.get(config, :damage_per_tick, 5))

      :poison ->
        poison(duration, Map.get(config, :damage_per_tick, 3))

      :freeze ->
        freeze(duration)

      :stun ->
        stun(duration)

      _ ->
        %Effect{type: type, duration: duration}
    end
  end

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_existing_atom(value)
end
