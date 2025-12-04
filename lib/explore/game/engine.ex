defmodule Explore.Game.Engine do
  @moduledoc """
  Game engine GenServer managing game state and tick loop.

  The engine:
  - Manages the game world state
  - Runs the game tick loop
  - Handles player actions (placing towers, starting waves)
  - Broadcasts game events via PubSub
  """

  use GenServer

  alias Explore.Game.{World, Tick}
  alias Explore.Game.Map.GameMap
  alias Explore.Game.Config.{Loader, TowerConfig, WaveConfig}
  alias Explore.Game.Waves.Spawner
  alias Explore.Game.TechTree.Tree

  @tick_interval trunc(1000 / Tick.tick_rate())

  # Client API

  @doc """
  Starts a new game engine.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @doc """
  Starts a new game with the given level.
  """
  def start_game(pid, level_name \\ "level_01") do
    GenServer.call(pid, {:start_game, level_name})
  end

  @doc """
  Places a tower at the given position.
  """
  def place_tower(pid, tower_type, position) do
    GenServer.call(pid, {:place_tower, tower_type, position})
  end

  @doc """
  Removes a tower and refunds resources.
  """
  def sell_tower(pid, tower_id) do
    GenServer.call(pid, {:sell_tower, tower_id})
  end

  @doc """
  Starts the next wave.
  """
  def start_wave(pid) do
    GenServer.call(pid, :start_wave)
  end

  @doc """
  Pauses the game.
  """
  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  @doc """
  Resumes the game.
  """
  def resume(pid) do
    GenServer.call(pid, :resume)
  end

  @doc """
  Sets the game speed multiplier.
  """
  def set_speed(pid, speed) do
    GenServer.call(pid, {:set_speed, speed})
  end

  @doc """
  Gets the current game state.
  """
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  Enables or disables designer mode.
  """
  def set_designer_mode(pid, enabled) do
    GenServer.call(pid, {:set_designer_mode, enabled})
  end

  @doc """
  Designer mode: spawns an enemy.
  """
  def spawn_enemy(pid, enemy_type) do
    GenServer.call(pid, {:spawn_enemy, enemy_type})
  end

  @doc """
  Designer mode: sets resources.
  """
  def set_resources(pid, amount) do
    GenServer.call(pid, {:set_resources, amount})
  end

  @doc """
  Advances the game by one tick (for single-stepping).
  """
  def single_step(pid) do
    GenServer.call(pid, :single_step)
  end

  # Server Callbacks

  @impl true
  def init(opts) do
    state = %{
      world: World.new(),
      config: %{},
      level_config: %{},
      game_speed: 1.0,
      designer_mode: Keyword.get(opts, :designer_mode, false),
      spawner: nil,
      tech_tree: nil,
      pubsub_topic:
        Keyword.get(opts, :pubsub_topic, "game:#{:erlang.unique_integer([:positive])}")
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:start_game, level_name}, _from, state) do
    case load_game(level_name) do
      {:ok, new_state} ->
        # Start the tick loop
        schedule_tick()
        {:reply, :ok, Map.merge(state, new_state)}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:place_tower, tower_type, position}, _from, state) do
    tower_config = Loader.get_tower_config(state.config, tower_type)

    cond do
      tower_config == nil ->
        {:reply, {:error, :unknown_tower_type}, state}

      not can_build_tower?(state, tower_type) ->
        {:reply, {:error, :tower_not_unlocked}, state}

      not GameMap.can_place_tower?(state.world.map, position) ->
        {:reply, {:error, :invalid_position}, state}

      true ->
        cost = Map.get(tower_config, :cost, 100)

        # In designer mode, skip resource spending
        spend_result =
          if state.designer_mode do
            {:ok, state.world}
          else
            World.spend_resources(state.world, cost)
          end

        case spend_result do
          {:ok, world_after_spend} ->
            snapped_pos = GameMap.snap_to_grid(world_after_spend.map, position)
            tower = TowerConfig.to_tower(tower_type, snapped_pos, tower_config)

            {:ok, updated_map} = GameMap.place_tower(world_after_spend.map, snapped_pos)
            world_with_tower = World.add_tower(%{world_after_spend | map: updated_map}, tower)

            broadcast(state, {:tower_placed, tower})
            {:reply, {:ok, tower}, %{state | world: world_with_tower}}

          {:error, :insufficient_resources} ->
            {:reply, {:error, :insufficient_resources}, state}
        end
    end
  end

  @impl true
  def handle_call({:sell_tower, tower_id}, _from, state) do
    updated_world = World.remove_tower(state.world, tower_id)
    broadcast(state, {:tower_sold, tower_id})
    {:reply, :ok, %{state | world: updated_world}}
  end

  @impl true
  def handle_call(:start_wave, _from, state) do
    if state.world.state in [:waiting, :playing] do
      next_wave = state.world.current_wave + 1

      if next_wave <= state.world.total_waves do
        wave_config = WaveConfig.get_wave(state.level_config, next_wave)

        if wave_config do
          # Update wave number
          world = World.next_wave(state.world) |> World.set_state(:playing)

          # Start spawner for this wave
          spawner = Spawner.new(wave_config, state.config)

          broadcast(state, {:wave_started, next_wave})
          {:reply, :ok, %{state | world: world, spawner: spawner}}
        else
          {:reply, {:error, :no_wave_config}, state}
        end
      else
        {:reply, {:error, :no_more_waves}, state}
      end
    else
      {:reply, {:error, :invalid_state}, state}
    end
  end

  @impl true
  def handle_call(:pause, _from, state) do
    world = World.set_state(state.world, :paused)
    broadcast(state, :game_paused)
    {:reply, :ok, %{state | world: world}}
  end

  @impl true
  def handle_call(:resume, _from, state) do
    world = World.set_state(state.world, :playing)
    broadcast(state, :game_resumed)
    {:reply, :ok, %{state | world: world}}
  end

  @impl true
  def handle_call({:set_speed, speed}, _from, state) do
    clamped_speed = max(0.25, min(4.0, speed))
    {:reply, :ok, %{state | game_speed: clamped_speed}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, build_game_state(state), state}
  end

  @impl true
  def handle_call({:set_designer_mode, enabled}, _from, state) do
    {:reply, :ok, %{state | designer_mode: enabled}}
  end

  @impl true
  def handle_call({:spawn_enemy, enemy_type}, _from, state) do
    if state.designer_mode do
      enemy_config = Loader.get_enemy_config(state.config, enemy_type)

      if enemy_config do
        enemy = Explore.Game.Config.EnemyConfig.to_enemy(enemy_type, enemy_config)
        spawn_pos = GameMap.spawn_position(state.world.map)
        enemy = %{enemy | position: spawn_pos}

        world = World.add_enemy(state.world, enemy)
        {:reply, {:ok, enemy}, %{state | world: world}}
      else
        {:reply, {:error, :unknown_enemy_type}, state}
      end
    else
      {:reply, {:error, :not_in_designer_mode}, state}
    end
  end

  @impl true
  def handle_call({:set_resources, amount}, _from, state) do
    if state.designer_mode do
      world = %{state.world | resources: max(0, amount)}
      {:reply, :ok, %{state | world: world}}
    else
      {:reply, {:error, :not_in_designer_mode}, state}
    end
  end

  @impl true
  def handle_call(:single_step, _from, state) do
    if state.world.state == :paused do
      {updated_world, updated_spawner} = process_tick(state)
      {:reply, :ok, %{state | world: updated_world, spawner: updated_spawner}}
    else
      {:reply, {:error, :not_paused}, state}
    end
  end

  @impl true
  def handle_info(:tick, state) do
    if state.world.state == :playing do
      {updated_world, updated_spawner} = process_tick(state)

      # Check for game over conditions
      updated_world =
        cond do
          updated_world.lives <= 0 ->
            broadcast(state, :game_over_loss)
            World.set_state(updated_world, :lost)

          updated_world.state == :won ->
            broadcast(state, :game_over_win)
            updated_world

          true ->
            updated_world
        end

      # Broadcast state update
      broadcast(state, {:state_updated, build_game_state(%{state | world: updated_world})})

      schedule_tick()
      {:noreply, %{state | world: updated_world, spawner: updated_spawner}}
    else
      schedule_tick()
      {:noreply, state}
    end
  end

  # Private functions

  defp load_game(level_name) do
    with {:ok, config} <- Loader.load_all(),
         {:ok, level_config} <- Loader.load_level(level_name),
         {:ok, map_config} <- load_map_for_level(level_config) do
      level = Map.get(level_config, :level, level_config)

      game_map = GameMap.new(map_config)

      world =
        World.new(
          map: game_map,
          resources: Map.get(level, :starting_resources, 500),
          lives: Map.get(level, :starting_lives, 20),
          total_waves: WaveConfig.wave_count(level)
        )

      tech_tree = Tree.new(config)

      {:ok,
       %{
         world: world,
         config: config,
         level_config: level,
         tech_tree: tech_tree
       }}
    end
  end

  defp load_map_for_level(level_config) do
    level = Map.get(level_config, :level, level_config)
    map_name = Map.get(level, :map, "windy_path")

    case Loader.load_map(map_name) do
      {:ok, config} ->
        {:ok, config}

      {:error, _} ->
        # Fall back to hardcoded map
        {:ok, Explore.Game.Map.Maps.WindyPath.config()}
    end
  end

  defp process_tick(state) do
    # Spawn enemies from current wave
    {world_after_spawn, updated_spawner} =
      if state.spawner do
        Spawner.tick(state.spawner, state.world, Tick.delta() * 1000 * state.game_speed)
      else
        {state.world, state.spawner}
      end

    # Process game tick
    world_after_tick = Tick.process(world_after_spawn, state.config)

    # Check if wave is complete
    {final_world, final_spawner} =
      if updated_spawner && Spawner.complete?(updated_spawner) &&
           map_size(world_after_tick.enemies) == 0 do
        broadcast(state, {:wave_complete, world_after_tick.current_wave})

        if world_after_tick.current_wave >= world_after_tick.total_waves do
          {World.set_state(world_after_tick, :won), nil}
        else
          {World.set_state(world_after_tick, :waiting), nil}
        end
      else
        {world_after_tick, updated_spawner}
      end

    {final_world, final_spawner}
  end

  defp can_build_tower?(state, tower_type) do
    state.designer_mode or Tree.tower_available?(state.tech_tree, tower_type)
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick_interval)
  end

  defp broadcast(state, message) do
    Phoenix.PubSub.broadcast(Explore.PubSub, state.pubsub_topic, message)
  end

  defp build_game_state(state) do
    %{
      world: state.world,
      game_speed: state.game_speed,
      designer_mode: state.designer_mode,
      tech_tree: state.tech_tree,
      available_towers: get_available_towers(state),
      config: %{
        towers: Map.get(state.config, :towers, %{}),
        enemies: Map.get(state.config, :enemies, %{})
      }
    }
  end

  defp get_available_towers(state) do
    if state.designer_mode do
      Map.keys(Map.get(state.config, :towers, %{}))
    else
      Tree.available_towers(state.tech_tree)
    end
  end
end
