defmodule Explore.Game.Entities.Minion do
  @moduledoc """
  Minion entity representing a spawned creature from towers (like walking bombs).

  Minions:
  - Move toward the nearest enemy
  - Explode on contact dealing damage
  - Have a limited lifetime
  """

  @type position :: {number(), number()}

  @type t :: %__MODULE__{
          id: String.t(),
          tower_id: String.t(),
          type: atom(),
          position: position(),
          target_id: String.t() | nil,
          damage: number(),
          damage_type: atom(),
          speed: number(),
          lifetime: non_neg_integer(),
          created_at: non_neg_integer(),
          aoe_radius: number()
        }

  defstruct id: nil,
            tower_id: nil,
            type: :walking_bomb,
            position: {0, 0},
            target_id: nil,
            damage: 30,
            damage_type: :physical,
            speed: 50,
            lifetime: 10_000,
            created_at: 0,
            aoe_radius: 30

  @doc """
  Creates a new minion at the given position.
  """
  @spec new(map()) :: t()
  def new(attrs) do
    id = generate_id()

    %__MODULE__{
      id: id,
      tower_id: Map.get(attrs, :tower_id),
      type: Map.get(attrs, :type, :walking_bomb),
      position: Map.get(attrs, :position, {0, 0}),
      damage: Map.get(attrs, :damage, 30),
      damage_type: Map.get(attrs, :damage_type, :physical),
      speed: Map.get(attrs, :speed, 50),
      lifetime: Map.get(attrs, :lifetime, 10_000),
      created_at: Map.get(attrs, :created_at, 0),
      aoe_radius: Map.get(attrs, :aoe_radius, 30)
    }
  end

  @doc """
  Moves the minion toward its target.
  Returns the updated minion.
  """
  @spec move(t(), position(), number()) :: t()
  def move(%__MODULE__{} = minion, target_position, delta) do
    {mx, my} = minion.position
    {tx, ty} = target_position

    dx = tx - mx
    dy = ty - my
    distance = :math.sqrt(dx * dx + dy * dy)

    if distance < 1 do
      minion
    else
      move_distance = minion.speed * delta
      ratio = min(1.0, move_distance / distance)

      new_x = mx + dx * ratio
      new_y = my + dy * ratio

      %{minion | position: {new_x, new_y}}
    end
  end

  @doc """
  Sets the minion's target.
  """
  @spec set_target(t(), String.t() | nil) :: t()
  def set_target(%__MODULE__{} = minion, target_id) do
    %{minion | target_id: target_id}
  end

  @doc """
  Checks if the minion has reached its target (within explosion range).
  """
  @spec reached_target?(t(), position()) :: boolean()
  def reached_target?(%__MODULE__{position: pos, aoe_radius: radius}, target_position) do
    distance(pos, target_position) <= radius
  end

  @doc """
  Checks if the minion's lifetime has expired.
  """
  @spec expired?(t(), non_neg_integer()) :: boolean()
  def expired?(%__MODULE__{created_at: created, lifetime: lifetime}, current_tick_ms) do
    current_tick_ms - created >= lifetime
  end

  @doc """
  Gets the remaining lifetime in milliseconds.
  """
  @spec remaining_lifetime(t(), non_neg_integer()) :: non_neg_integer()
  def remaining_lifetime(%__MODULE__{created_at: created, lifetime: lifetime}, current_tick_ms) do
    max(0, lifetime - (current_tick_ms - created))
  end

  @doc """
  Calculates distance from the minion to a position.
  """
  @spec distance_to(t(), position()) :: number()
  def distance_to(%__MODULE__{position: pos}, target) do
    distance(pos, target)
  end

  defp distance({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    :math.sqrt(dx * dx + dy * dy)
  end

  defp generate_id do
    "minion_#{:erlang.unique_integer([:positive])}"
  end
end
