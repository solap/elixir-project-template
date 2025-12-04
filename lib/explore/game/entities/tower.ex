defmodule Explore.Game.Entities.Tower do
  @moduledoc """
  Tower entity representing a defensive structure placed by the player.

  Towers can:
  - Target enemies within their range
  - Fire projectiles or apply effects
  - Have various damage types and special abilities
  """

  @type damage_type :: :physical | :fire | :ice | :lightning | :poison
  @type targeting_strategy :: :first | :last | :closest | :strongest | :weakest

  @type position :: {number(), number()}

  @type stats :: %{
          damage: number(),
          damage_type: damage_type(),
          range: number(),
          fire_rate: number(),
          projectile_speed: number(),
          aoe_radius: number() | nil,
          chain_targets: non_neg_integer() | nil,
          chain_damage_falloff: number() | nil,
          spawn_interval: number() | nil
        }

  @type effect_config :: %{
          type: atom(),
          duration: non_neg_integer(),
          strength: number() | nil,
          damage_per_tick: number() | nil
        }

  @type special_config :: %{
          spawn_minion: map() | nil
        }

  @type visual_config :: %{
          color: String.t() | nil,
          accent: String.t() | nil,
          projectile_type: atom() | nil
        }

  @type t :: %__MODULE__{
          id: String.t(),
          type: atom(),
          name: String.t(),
          position: position(),
          stats: stats(),
          cost: non_neg_integer(),
          targeting: targeting_strategy(),
          effects: list(effect_config()),
          special: special_config() | nil,
          visual: visual_config(),
          cooldown: number(),
          target_id: String.t() | nil,
          last_spawn_tick: non_neg_integer()
        }

  defstruct id: nil,
            type: nil,
            name: "",
            position: {0, 0},
            stats: %{
              damage: 10,
              damage_type: :physical,
              range: 100,
              fire_rate: 1.0,
              projectile_speed: 300,
              aoe_radius: nil,
              chain_targets: nil,
              chain_damage_falloff: nil,
              spawn_interval: nil
            },
            cost: 100,
            targeting: :first,
            effects: [],
            special: nil,
            visual: %{color: nil, accent: nil, projectile_type: :arrow},
            cooldown: 0.0,
            target_id: nil,
            last_spawn_tick: 0

  @doc """
  Creates a new tower with the given type and position.
  """
  @spec new(atom(), position(), map()) :: t()
  def new(type, position, config \\ %{}) do
    id = generate_id()

    stats =
      Map.merge(
        %{
          damage: 10,
          damage_type: :physical,
          range: 100,
          fire_rate: 1.0,
          projectile_speed: 300,
          aoe_radius: nil,
          chain_targets: nil,
          chain_damage_falloff: nil,
          spawn_interval: nil
        },
        Map.get(config, :stats, %{})
      )

    visual_config = Map.get(config, :visual, %{})

    visual =
      Map.merge(
        %{color: nil, accent: nil, projectile_type: :arrow},
        normalize_visual(visual_config)
      )

    %__MODULE__{
      id: id,
      type: type,
      name: Map.get(config, :name, to_string(type)),
      position: position,
      stats: stats,
      cost: Map.get(config, :cost, 100),
      targeting: Map.get(config, :targeting, :first),
      effects: Map.get(config, :effects, []),
      special: Map.get(config, :special),
      visual: visual
    }
  end

  defp normalize_visual(visual) do
    visual
    |> Map.update(:projectile_type, :arrow, fn
      val when is_atom(val) -> val
      val when is_binary(val) -> String.to_atom(val)
      _ -> :arrow
    end)
  end

  @doc """
  Checks if the tower can fire (cooldown expired).
  """
  @spec can_fire?(t()) :: boolean()
  def can_fire?(%__MODULE__{cooldown: cooldown}) do
    cooldown <= 0
  end

  @doc """
  Resets the tower's cooldown after firing.
  The cooldown is based on fire_rate (shots per second).
  """
  @spec reset_cooldown(t()) :: t()
  def reset_cooldown(%__MODULE__{stats: stats} = tower) do
    fire_rate = Map.get(stats, :fire_rate, 1.0)
    cooldown_time = if fire_rate > 0, do: 1.0 / fire_rate, else: 1.0
    %{tower | cooldown: cooldown_time}
  end

  @doc """
  Updates the tower's cooldown by the given delta time (in seconds).
  """
  @spec update_cooldown(t(), number()) :: t()
  def update_cooldown(%__MODULE__{cooldown: cooldown} = tower, delta) do
    %{tower | cooldown: max(0, cooldown - delta)}
  end

  @doc """
  Sets the tower's current target.
  """
  @spec set_target(t(), String.t() | nil) :: t()
  def set_target(%__MODULE__{} = tower, target_id) do
    %{tower | target_id: target_id}
  end

  @doc """
  Gets the tower's range.
  """
  @spec range(t()) :: number()
  def range(%__MODULE__{stats: stats}) do
    Map.get(stats, :range, 100)
  end

  @doc """
  Gets the tower's damage.
  """
  @spec damage(t()) :: number()
  def damage(%__MODULE__{stats: stats}) do
    Map.get(stats, :damage, 10)
  end

  @doc """
  Gets the tower's damage type.
  """
  @spec damage_type(t()) :: damage_type()
  def damage_type(%__MODULE__{stats: stats}) do
    Map.get(stats, :damage_type, :physical)
  end

  @doc """
  Checks if the tower has AOE (area of effect).
  """
  @spec has_aoe?(t()) :: boolean()
  def has_aoe?(%__MODULE__{stats: stats}) do
    aoe = Map.get(stats, :aoe_radius)
    aoe != nil and aoe > 0
  end

  @doc """
  Gets the AOE radius, or 0 if no AOE.
  """
  @spec aoe_radius(t()) :: number()
  def aoe_radius(%__MODULE__{stats: stats}) do
    Map.get(stats, :aoe_radius) || 0
  end

  @doc """
  Checks if the tower has chain lightning ability.
  """
  @spec has_chain?(t()) :: boolean()
  def has_chain?(%__MODULE__{stats: stats}) do
    chains = Map.get(stats, :chain_targets)
    chains != nil and chains > 0
  end

  @doc """
  Gets the chain target count.
  """
  @spec chain_targets(t()) :: non_neg_integer()
  def chain_targets(%__MODULE__{stats: stats}) do
    Map.get(stats, :chain_targets) || 0
  end

  @doc """
  Checks if the tower spawns minions.
  """
  @spec spawns_minions?(t()) :: boolean()
  def spawns_minions?(%__MODULE__{special: special}) do
    special != nil and Map.has_key?(special, :spawn_minion)
  end

  @doc """
  Checks if it's time to spawn a minion.
  """
  @spec can_spawn_minion?(t(), non_neg_integer(), number()) :: boolean()
  def can_spawn_minion?(%__MODULE__{} = tower, current_tick, tick_rate) do
    if spawns_minions?(tower) do
      spawn_interval = get_in(tower.stats, [:spawn_interval]) || 5.0
      ticks_since_spawn = current_tick - tower.last_spawn_tick
      seconds_since_spawn = ticks_since_spawn / tick_rate
      seconds_since_spawn >= spawn_interval
    else
      false
    end
  end

  @doc """
  Updates the last spawn tick.
  """
  @spec update_spawn_tick(t(), non_neg_integer()) :: t()
  def update_spawn_tick(%__MODULE__{} = tower, tick) do
    %{tower | last_spawn_tick: tick}
  end

  @doc """
  Calculates the distance from the tower to a position.
  """
  @spec distance_to(t(), position()) :: number()
  def distance_to(%__MODULE__{position: {tx, ty}}, {px, py}) do
    dx = tx - px
    dy = ty - py
    :math.sqrt(dx * dx + dy * dy)
  end

  @doc """
  Checks if a position is within the tower's range.
  """
  @spec in_range?(t(), position()) :: boolean()
  def in_range?(%__MODULE__{} = tower, position) do
    distance_to(tower, position) <= range(tower)
  end

  @doc """
  Gets the tower's projectile type from visual config.
  """
  @spec projectile_type(t()) :: atom()
  def projectile_type(%__MODULE__{visual: visual}) do
    Map.get(visual, :projectile_type, :arrow)
  end

  defp generate_id do
    "tower_#{:erlang.unique_integer([:positive])}"
  end
end
