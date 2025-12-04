defmodule Explore.Game.World do
  @moduledoc """
  The game world state containing all entities, map, and game status.

  The world is the central data structure that tracks:
  - Map configuration and path
  - All towers placed by the player
  - All enemies currently alive
  - All projectiles in flight
  - Player resources and lives
  - Current game state and tick
  """

  alias Explore.Game.Entities.{Tower, Enemy, Projectile, Minion}
  alias Explore.Game.Map.GameMap

  @type game_state :: :waiting | :playing | :paused | :won | :lost

  @type t :: %__MODULE__{
          map: GameMap.t() | nil,
          towers: %{String.t() => Tower.t()},
          enemies: %{String.t() => Enemy.t()},
          projectiles: %{String.t() => Projectile.t()},
          minions: %{String.t() => Minion.t()},
          tick: non_neg_integer(),
          state: game_state(),
          resources: non_neg_integer(),
          lives: non_neg_integer(),
          max_lives: non_neg_integer(),
          score: non_neg_integer(),
          current_wave: non_neg_integer(),
          total_waves: non_neg_integer(),
          effects: list(map())
        }

  defstruct map: nil,
            towers: %{},
            enemies: %{},
            projectiles: %{},
            minions: %{},
            tick: 0,
            state: :waiting,
            resources: 500,
            lives: 20,
            max_lives: 20,
            score: 0,
            current_wave: 0,
            total_waves: 10,
            effects: []

  @doc """
  Creates a new world with the given options.

  ## Options
    - `:map` - The game map to use
    - `:resources` - Starting resources (default: 500)
    - `:lives` - Starting lives (default: 20)
    - `:total_waves` - Total number of waves (default: 10)
  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    resources = Keyword.get(opts, :resources, 500)
    lives = Keyword.get(opts, :lives, 20)
    total_waves = Keyword.get(opts, :total_waves, 10)
    map = Keyword.get(opts, :map)

    %__MODULE__{
      map: map,
      resources: resources,
      lives: lives,
      max_lives: lives,
      total_waves: total_waves
    }
  end

  @doc """
  Adds a tower to the world.
  """
  @spec add_tower(t(), Tower.t()) :: t()
  def add_tower(%__MODULE__{} = world, %Tower{} = tower) do
    %{world | towers: Map.put(world.towers, tower.id, tower)}
  end

  @doc """
  Removes a tower from the world and returns a portion of its cost.
  """
  @spec remove_tower(t(), String.t(), float()) :: t()
  def remove_tower(%__MODULE__{} = world, tower_id, refund_percentage \\ 0.5) do
    case Map.get(world.towers, tower_id) do
      nil ->
        world

      tower ->
        refund = trunc(tower.cost * refund_percentage)

        %{
          world
          | towers: Map.delete(world.towers, tower_id),
            resources: world.resources + refund
        }
    end
  end

  @doc """
  Adds an enemy to the world.
  """
  @spec add_enemy(t(), Enemy.t()) :: t()
  def add_enemy(%__MODULE__{} = world, %Enemy{} = enemy) do
    %{world | enemies: Map.put(world.enemies, enemy.id, enemy)}
  end

  @doc """
  Removes an enemy from the world.
  """
  @spec remove_enemy(t(), String.t()) :: t()
  def remove_enemy(%__MODULE__{} = world, enemy_id) do
    %{world | enemies: Map.delete(world.enemies, enemy_id)}
  end

  @doc """
  Adds a projectile to the world.
  """
  @spec add_projectile(t(), Projectile.t()) :: t()
  def add_projectile(%__MODULE__{} = world, %Projectile{} = projectile) do
    %{world | projectiles: Map.put(world.projectiles, projectile.id, projectile)}
  end

  @doc """
  Removes a projectile from the world.
  """
  @spec remove_projectile(t(), String.t()) :: t()
  def remove_projectile(%__MODULE__{} = world, projectile_id) do
    %{world | projectiles: Map.delete(world.projectiles, projectile_id)}
  end

  @doc """
  Adds a minion to the world.
  """
  @spec add_minion(t(), Minion.t()) :: t()
  def add_minion(%__MODULE__{} = world, %Minion{} = minion) do
    %{world | minions: Map.put(world.minions, minion.id, minion)}
  end

  @doc """
  Removes a minion from the world.
  """
  @spec remove_minion(t(), String.t()) :: t()
  def remove_minion(%__MODULE__{} = world, minion_id) do
    %{world | minions: Map.delete(world.minions, minion_id)}
  end

  @doc """
  Deducts resources if the player can afford the cost.
  Returns {:ok, world} if successful, {:error, :insufficient_resources} otherwise.
  """
  @spec spend_resources(t(), non_neg_integer()) :: {:ok, t()} | {:error, :insufficient_resources}
  def spend_resources(%__MODULE__{} = world, cost) when cost >= 0 do
    if world.resources >= cost do
      {:ok, %{world | resources: world.resources - cost}}
    else
      {:error, :insufficient_resources}
    end
  end

  @doc """
  Adds resources to the world (e.g., from killing enemies).
  """
  @spec add_resources(t(), non_neg_integer()) :: t()
  def add_resources(%__MODULE__{} = world, amount) when amount >= 0 do
    %{world | resources: world.resources + amount}
  end

  @doc """
  Loses a life when an enemy reaches the end.
  Returns the updated world and whether the game is over.
  """
  @spec lose_life(t()) :: {t(), boolean()}
  def lose_life(%__MODULE__{} = world) do
    new_lives = max(0, world.lives - 1)
    game_over = new_lives == 0
    new_state = if game_over, do: :lost, else: world.state

    {%{world | lives: new_lives, state: new_state}, game_over}
  end

  @doc """
  Increments the score.
  """
  @spec add_score(t(), non_neg_integer()) :: t()
  def add_score(%__MODULE__{} = world, points) when points >= 0 do
    %{world | score: world.score + points}
  end

  @doc """
  Advances to the next wave.
  """
  @spec next_wave(t()) :: t()
  def next_wave(%__MODULE__{} = world) do
    new_wave = world.current_wave + 1
    new_state = if new_wave >= world.total_waves, do: :won, else: world.state

    %{world | current_wave: new_wave, state: new_state}
  end

  @doc """
  Increments the tick counter.
  """
  @spec tick(t()) :: t()
  def tick(%__MODULE__{} = world) do
    %{world | tick: world.tick + 1}
  end

  @doc """
  Sets the game state.
  """
  @spec set_state(t(), game_state()) :: t()
  def set_state(%__MODULE__{} = world, state) do
    %{world | state: state}
  end

  @doc """
  Adds a visual effect to the world.
  """
  @spec add_effect(t(), map()) :: t()
  def add_effect(%__MODULE__{} = world, effect) do
    %{world | effects: [effect | world.effects]}
  end

  @doc """
  Clears expired effects.
  """
  @spec clear_expired_effects(t(), non_neg_integer()) :: t()
  def clear_expired_effects(%__MODULE__{} = world, current_tick) do
    active_effects =
      Enum.filter(world.effects, fn effect ->
        Map.get(effect, :expires_at, current_tick + 1) > current_tick
      end)

    %{world | effects: active_effects}
  end
end
