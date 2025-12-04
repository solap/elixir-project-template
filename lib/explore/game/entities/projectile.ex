defmodule Explore.Game.Entities.Projectile do
  @moduledoc """
  Projectile entity representing a shot fired by a tower.

  Projectiles:
  - Move toward their target
  - Deal damage on hit
  - Can have AOE effects
  - Can apply status effects
  """

  alias Explore.Game.Combat.Effects.Effect

  @type position :: {number(), number()}
  @type damage_type :: :physical | :fire | :ice | :lightning | :poison

  @type t :: %__MODULE__{
          id: String.t(),
          tower_id: String.t(),
          target_id: String.t(),
          position: position(),
          target_position: position(),
          damage: number(),
          damage_type: damage_type(),
          speed: number(),
          aoe_radius: number(),
          effects: list(Effect.t()),
          chain_targets: non_neg_integer(),
          chain_damage_falloff: number(),
          hit: boolean()
        }

  defstruct id: nil,
            tower_id: nil,
            target_id: nil,
            position: {0, 0},
            target_position: {0, 0},
            damage: 10,
            damage_type: :physical,
            speed: 300,
            aoe_radius: 0,
            effects: [],
            chain_targets: 0,
            chain_damage_falloff: 0.7,
            hit: false

  @doc """
  Creates a new projectile from a tower toward a target.
  """
  @spec new(map()) :: t()
  def new(attrs) do
    id = generate_id()

    %__MODULE__{
      id: id,
      tower_id: Map.get(attrs, :tower_id),
      target_id: Map.get(attrs, :target_id),
      position: Map.get(attrs, :position, {0, 0}),
      target_position: Map.get(attrs, :target_position, {0, 0}),
      damage: Map.get(attrs, :damage, 10),
      damage_type: Map.get(attrs, :damage_type, :physical),
      speed: Map.get(attrs, :speed, 300),
      aoe_radius: Map.get(attrs, :aoe_radius, 0),
      effects: Map.get(attrs, :effects, []),
      chain_targets: Map.get(attrs, :chain_targets, 0),
      chain_damage_falloff: Map.get(attrs, :chain_damage_falloff, 0.7)
    }
  end

  @doc """
  Moves the projectile toward its target position.
  Returns the updated projectile.
  """
  @spec move(t(), number()) :: t()
  def move(%__MODULE__{} = projectile, delta) do
    {px, py} = projectile.position
    {tx, ty} = projectile.target_position

    dx = tx - px
    dy = ty - py
    distance = :math.sqrt(dx * dx + dy * dy)

    if distance < 1 do
      # Reached target
      %{projectile | position: projectile.target_position, hit: true}
    else
      # Move toward target
      move_distance = projectile.speed * delta
      ratio = min(1.0, move_distance / distance)

      new_x = px + dx * ratio
      new_y = py + dy * ratio

      %{projectile | position: {new_x, new_y}}
    end
  end

  @doc """
  Updates the target position (for tracking moving targets).
  """
  @spec update_target_position(t(), position()) :: t()
  def update_target_position(%__MODULE__{} = projectile, position) do
    %{projectile | target_position: position}
  end

  @doc """
  Checks if the projectile has hit its target.
  """
  @spec hit?(t()) :: boolean()
  def hit?(%__MODULE__{hit: hit}), do: hit

  @doc """
  Checks if the projectile has reached its target position.
  """
  @spec reached_target?(t()) :: boolean()
  def reached_target?(%__MODULE__{position: pos, target_position: target}) do
    distance(pos, target) < 5
  end

  @doc """
  Marks the projectile as having hit.
  """
  @spec mark_hit(t()) :: t()
  def mark_hit(%__MODULE__{} = projectile) do
    %{projectile | hit: true}
  end

  @doc """
  Checks if the projectile has AOE.
  """
  @spec has_aoe?(t()) :: boolean()
  def has_aoe?(%__MODULE__{aoe_radius: radius}) do
    radius > 0
  end

  @doc """
  Checks if the projectile chains to multiple targets.
  """
  @spec has_chain?(t()) :: boolean()
  def has_chain?(%__MODULE__{chain_targets: targets}) do
    targets > 0
  end

  @doc """
  Calculates damage for a chained hit (reduced by falloff).
  """
  @spec chain_damage(t(), non_neg_integer()) :: number()
  def chain_damage(%__MODULE__{damage: damage, chain_damage_falloff: falloff}, chain_index) do
    damage * :math.pow(falloff, chain_index)
  end

  defp distance({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    :math.sqrt(dx * dx + dy * dy)
  end

  defp generate_id do
    "projectile_#{:erlang.unique_integer([:positive])}"
  end
end
