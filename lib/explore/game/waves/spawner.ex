defmodule Explore.Game.Waves.Spawner do
  @moduledoc """
  Wave spawning logic.

  Manages the spawning of enemies for a wave over time.
  """

  alias Explore.Game.World
  alias Explore.Game.Map.GameMap
  alias Explore.Game.Waves.Wave
  alias Explore.Game.Config.{Loader, EnemyConfig}

  @type spawn_state :: %{
          type: atom(),
          remaining: non_neg_integer(),
          interval: non_neg_integer(),
          time_until_next: non_neg_integer()
        }

  @type t :: %__MODULE__{
          wave: Wave.t(),
          spawn_states: list(spawn_state()),
          complete: boolean(),
          config: map()
        }

  defstruct wave: nil,
            spawn_states: [],
            complete: false,
            config: %{}

  @doc """
  Creates a new spawner for a wave.
  """
  @spec new(map(), map()) :: t()
  def new(wave_config, game_config) do
    wave = Wave.new(wave_config)

    spawn_states =
      wave.enemy_groups
      |> Enum.map(fn group ->
        %{
          type: group.type,
          remaining: group.count,
          interval: group.interval,
          time_until_next: 0
        }
      end)

    %__MODULE__{
      wave: wave,
      spawn_states: spawn_states,
      complete: false,
      config: game_config
    }
  end

  @doc """
  Processes a spawner tick, potentially spawning enemies.
  Returns {updated_world, updated_spawner}.
  """
  @spec tick(t(), World.t(), number()) :: {World.t(), t()}
  def tick(%__MODULE__{complete: true} = spawner, world, _delta_ms) do
    {world, spawner}
  end

  def tick(%__MODULE__{} = spawner, world, delta_ms) do
    {updated_world, updated_states} =
      spawner.spawn_states
      |> Enum.reduce({world, []}, fn state, {world_acc, states_acc} ->
        {new_world, new_state} = process_spawn_state(state, world_acc, delta_ms, spawner.config)
        {new_world, [new_state | states_acc]}
      end)

    # Reverse to maintain order
    updated_states = Enum.reverse(updated_states)

    # Check if all spawning is complete
    all_complete = Enum.all?(updated_states, fn s -> s.remaining <= 0 end)

    {updated_world, %{spawner | spawn_states: updated_states, complete: all_complete}}
  end

  @doc """
  Checks if the spawner has finished spawning all enemies.
  """
  @spec complete?(t()) :: boolean()
  def complete?(%__MODULE__{complete: complete}), do: complete

  @doc """
  Gets the number of remaining enemies to spawn.
  """
  @spec remaining_enemies(t()) :: non_neg_integer()
  def remaining_enemies(%__MODULE__{spawn_states: states}) do
    Enum.reduce(states, 0, fn state, acc -> acc + state.remaining end)
  end

  # Process a single spawn state
  defp process_spawn_state(state, world, delta_ms, config) do
    if state.remaining <= 0 do
      {world, state}
    else
      new_time = state.time_until_next - delta_ms

      if new_time <= 0 do
        # Spawn an enemy
        enemy = create_enemy(state.type, world, config)
        updated_world = World.add_enemy(world, enemy)

        new_state = %{
          state
          | remaining: state.remaining - 1,
            time_until_next: state.interval
        }

        {updated_world, new_state}
      else
        {world, %{state | time_until_next: new_time}}
      end
    end
  end

  # Create an enemy of the given type
  defp create_enemy(type, world, config) do
    enemy_config = Loader.get_enemy_config(config, type) || %{name: to_string(type)}
    enemy = EnemyConfig.to_enemy(type, enemy_config)

    # Set spawn position
    spawn_pos = GameMap.spawn_position(world.map)
    %{enemy | position: spawn_pos, path_progress: 0.0}
  end
end
