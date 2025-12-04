defmodule Explore.Game.Tick do
  @moduledoc """
  Game tick processing logic.

  Each tick updates the game state by:
  1. Moving enemies along the path
  2. Updating tower cooldowns and firing
  3. Moving projectiles
  4. Processing hits and damage
  5. Applying and ticking effects
  6. Removing dead enemies
  7. Checking win/lose conditions
  """

  alias Explore.Game.World
  alias Explore.Game.Entities.{Tower, Enemy, Projectile, Minion}
  alias Explore.Game.Combat.{Targeting, Damage, Effects}
  alias Explore.Game.Config.{EnemyConfig}

  @tick_rate 60
  @delta 1 / @tick_rate

  @doc """
  Gets the tick rate (ticks per second).
  """
  @spec tick_rate() :: number()
  def tick_rate, do: @tick_rate

  @doc """
  Gets the delta time per tick in seconds.
  """
  @spec delta() :: number()
  def delta, do: @delta

  @doc """
  Processes a single game tick, returning the updated world.
  """
  @spec process(World.t(), map()) :: World.t()
  def process(%World{state: state} = world, config) when state in [:playing] do
    world
    |> World.tick()
    |> move_enemies()
    |> tick_enemy_effects()
    |> apply_enemy_regeneration()
    |> update_tower_cooldowns()
    |> process_tower_firing(config)
    |> move_projectiles()
    |> process_projectile_hits(config)
    |> update_minions()
    |> remove_dead_entities(config)
    |> check_enemies_reached_end()
    |> World.clear_expired_effects(world.tick)
  end

  def process(%World{} = world, _config), do: world

  # Move all enemies along their path
  defp move_enemies(%World{} = world) do
    path_length = Explore.Game.Map.GameMap.path_length(world.map)

    updated_enemies =
      world.enemies
      |> Enum.map(fn {id, enemy} ->
        {updated, _reached_end} = Enemy.move(enemy, @delta, path_length)
        new_pos = Explore.Game.Map.GameMap.position_at_progress(world.map, updated.path_progress)
        {id, Enemy.set_position(updated, new_pos)}
      end)
      |> Map.new()

    %{world | enemies: updated_enemies}
  end

  # Update effect durations and apply tick damage
  defp tick_enemy_effects(%World{} = world) do
    delta_ms = @delta * 1000

    updated_enemies =
      world.enemies
      |> Enum.map(fn {id, enemy} ->
        {id, Enemy.tick_effects(enemy, delta_ms)}
      end)
      |> Map.new()

    %{world | enemies: updated_enemies}
  end

  # Apply regeneration to enemies that have it
  defp apply_enemy_regeneration(%World{} = world) do
    delta_ms = @delta * 1000

    updated_enemies =
      world.enemies
      |> Enum.map(fn {id, enemy} ->
        {id, Enemy.apply_regeneration(enemy, delta_ms)}
      end)
      |> Map.new()

    %{world | enemies: updated_enemies}
  end

  # Update tower cooldowns
  defp update_tower_cooldowns(%World{} = world) do
    updated_towers =
      world.towers
      |> Enum.map(fn {id, tower} ->
        {id, Tower.update_cooldown(tower, @delta)}
      end)
      |> Map.new()

    %{world | towers: updated_towers}
  end

  # Process tower targeting and firing
  defp process_tower_firing(%World{} = world, config) do
    {updated_towers, new_projectiles} =
      world.towers
      |> Enum.reduce({world.towers, []}, fn {id, tower}, {towers_acc, projectiles_acc} ->
        if Tower.can_fire?(tower) and not Tower.spawns_minions?(tower) do
          target_id = Targeting.find_target(tower, world.enemies, tower.targeting)

          if target_id do
            target = Map.get(world.enemies, target_id)

            if target do
              projectile = create_projectile(tower, target)
              updated_tower = tower |> Tower.reset_cooldown() |> Tower.set_target(target_id)
              {Map.put(towers_acc, id, updated_tower), [projectile | projectiles_acc]}
            else
              {towers_acc, projectiles_acc}
            end
          else
            {towers_acc, projectiles_acc}
          end
        else
          {towers_acc, projectiles_acc}
        end
      end)

    # Add new projectiles to world
    world_with_projectiles =
      Enum.reduce(new_projectiles, %{world | towers: updated_towers}, fn proj, acc ->
        World.add_projectile(acc, proj)
      end)

    # Handle minion spawning towers
    process_minion_spawning(world_with_projectiles, config)
  end

  # Handle towers that spawn minions
  defp process_minion_spawning(%World{} = world, _config) do
    tick_ms = world.tick * (@delta * 1000)

    {updated_towers, new_minions} =
      world.towers
      |> Enum.filter(fn {_id, tower} -> Tower.spawns_minions?(tower) end)
      |> Enum.reduce({world.towers, []}, fn {id, tower}, {towers_acc, minions_acc} ->
        if Tower.can_spawn_minion?(tower, world.tick, @tick_rate) do
          minion = create_minion(tower, tick_ms)
          updated_tower = Tower.update_spawn_tick(tower, world.tick)
          {Map.put(towers_acc, id, updated_tower), [minion | minions_acc]}
        else
          {towers_acc, minions_acc}
        end
      end)

    Enum.reduce(new_minions, %{world | towers: updated_towers}, fn minion, acc ->
      World.add_minion(acc, minion)
    end)
  end

  # Create a projectile from tower to target
  defp create_projectile(tower, target) do
    Projectile.new(%{
      tower_id: tower.id,
      target_id: target.id,
      position: tower.position,
      target_position: target.position,
      damage: Tower.damage(tower),
      damage_type: Tower.damage_type(tower),
      speed: Map.get(tower.stats, :projectile_speed, 300),
      aoe_radius: Tower.aoe_radius(tower),
      effects: tower.effects,
      chain_targets: Tower.chain_targets(tower),
      chain_damage_falloff: Map.get(tower.stats, :chain_damage_falloff, 0.7)
    })
  end

  # Create a minion from a tower
  defp create_minion(tower, current_tick_ms) do
    spawn_config = get_in(tower.special, [:spawn_minion]) || %{}

    Minion.new(%{
      tower_id: tower.id,
      type: Map.get(spawn_config, :type, :walking_bomb),
      position: tower.position,
      damage: Map.get(spawn_config, :damage, 30),
      speed: Map.get(spawn_config, :speed, 50),
      lifetime: Map.get(spawn_config, :lifetime, 10_000),
      created_at: current_tick_ms
    })
  end

  # Move all projectiles toward their targets
  defp move_projectiles(%World{} = world) do
    updated_projectiles =
      world.projectiles
      |> Enum.map(fn {id, projectile} ->
        # Update target position if target still exists and is alive
        projectile =
          case Map.get(world.enemies, projectile.target_id) do
            nil -> projectile
            target -> Projectile.update_target_position(projectile, target.position)
          end

        {id, Projectile.move(projectile, @delta)}
      end)
      |> Map.new()

    %{world | projectiles: updated_projectiles}
  end

  # Process projectiles that have hit their targets
  defp process_projectile_hits(%World{} = world, _config) do
    {remaining_projectiles, world_after_hits} =
      world.projectiles
      |> Enum.reduce({%{}, world}, fn {id, projectile}, {proj_acc, world_acc} ->
        if Projectile.reached_target?(projectile) do
          # Apply damage
          world_after_damage = apply_projectile_damage(world_acc, projectile)
          {proj_acc, world_after_damage}
        else
          {Map.put(proj_acc, id, projectile), world_acc}
        end
      end)

    %{world_after_hits | projectiles: remaining_projectiles}
  end

  # Apply damage from a projectile hit
  defp apply_projectile_damage(%World{} = world, projectile) do
    world =
      if Projectile.has_aoe?(projectile) do
        # AOE damage to all enemies in radius
        damages =
          Damage.calculate_aoe_damage(
            projectile.damage,
            projectile.damage_type,
            projectile.target_position,
            projectile.aoe_radius,
            Map.values(world.enemies)
          )

        apply_damage_list(world, damages, projectile.damage_type, projectile.effects)
      else
        # Single target damage
        apply_single_damage(
          world,
          projectile.target_id,
          projectile.damage,
          projectile.damage_type,
          projectile.effects
        )
      end

    # Handle chain lightning
    if Projectile.has_chain?(projectile) do
      apply_chain_damage(world, projectile)
    else
      world
    end
  end

  # Apply damage to a list of enemies
  defp apply_damage_list(%World{} = world, damage_list, damage_type, effects) do
    Enum.reduce(damage_list, world, fn {enemy_id, damage}, acc ->
      apply_single_damage(acc, enemy_id, damage, damage_type, effects)
    end)
  end

  # Apply damage to a single enemy
  defp apply_single_damage(%World{} = world, enemy_id, damage, damage_type, effects) do
    case Map.get(world.enemies, enemy_id) do
      nil ->
        world

      enemy ->
        {updated_enemy, _actual_damage} = Enemy.take_damage(enemy, damage, damage_type)

        # Apply effects
        updated_enemy =
          Enum.reduce(effects, updated_enemy, fn effect_config, acc ->
            effect = Effects.from_config(effect_config)
            Enemy.apply_effect(acc, effect)
          end)

        %{world | enemies: Map.put(world.enemies, enemy_id, updated_enemy)}
    end
  end

  # Apply chain lightning damage
  defp apply_chain_damage(%World{} = world, projectile) do
    # Find enemies near the target, excluding the primary target
    nearby_enemies =
      Targeting.get_enemies_in_radius(
        projectile.target_position,
        150,
        world.enemies
      )
      |> Enum.reject(fn e -> e.id == projectile.target_id end)

    damages =
      Damage.calculate_chain_damage(
        projectile.damage,
        projectile.damage_type,
        nearby_enemies,
        projectile.chain_targets,
        projectile.chain_damage_falloff
      )

    apply_damage_list(world, damages, projectile.damage_type, [])
  end

  # Update minion positions and check for hits
  defp update_minions(%World{} = world) do
    tick_ms = world.tick * (@delta * 1000)

    {remaining_minions, world_after_minion_hits} =
      world.minions
      |> Enum.reduce({%{}, world}, fn {id, minion}, {minions_acc, world_acc} ->
        # Check if expired
        if Minion.expired?(minion, tick_ms) do
          {minions_acc, world_acc}
        else
          # Find nearest enemy
          case Targeting.find_closest_enemy(minion.position, world_acc.enemies) do
            nil ->
              {Map.put(minions_acc, id, minion), world_acc}

            target ->
              # Move toward target
              updated_minion = Minion.move(minion, target.position, @delta)

              # Check if reached target
              if Minion.reached_target?(updated_minion, target.position) do
                # Explode and deal AOE damage
                damages =
                  Damage.calculate_aoe_damage(
                    minion.damage,
                    minion.damage_type,
                    minion.position,
                    minion.aoe_radius,
                    Map.values(world_acc.enemies)
                  )

                world_after_explosion =
                  apply_damage_list(world_acc, damages, minion.damage_type, [])

                {minions_acc, world_after_explosion}
              else
                {Map.put(minions_acc, id, updated_minion), world_acc}
              end
          end
        end
      end)

    %{world_after_minion_hits | minions: remaining_minions}
  end

  # Remove dead enemies and grant rewards
  defp remove_dead_entities(%World{} = world, config) do
    {alive_enemies, dead_enemies} =
      world.enemies
      |> Map.values()
      |> Enum.split_with(fn enemy -> not Enemy.dead?(enemy) end)

    # Calculate rewards and handle splitting
    {total_reward, new_enemies} =
      Enum.reduce(dead_enemies, {0, []}, fn enemy, {reward_acc, new_enemies_acc} ->
        reward = reward_acc + enemy.reward

        # Handle splitting enemies
        new = handle_enemy_split(enemy, config)
        {reward, new_enemies_acc ++ new}
      end)

    # Update world with living enemies
    world_with_alive = %{world | enemies: Map.new(alive_enemies, fn e -> {e.id, e} end)}

    # Add new enemies from splitting
    world_with_new =
      Enum.reduce(new_enemies, world_with_alive, fn enemy, acc ->
        World.add_enemy(acc, enemy)
      end)

    # Add rewards
    World.add_resources(world_with_new, total_reward)
    |> World.add_score(total_reward)
  end

  # Handle enemies that split on death
  defp handle_enemy_split(enemy, config) do
    if Enemy.splits_on_death?(enemy) do
      split_config = Enemy.get_split_config(enemy)
      count = Map.get(split_config, :count, 2)
      type = Map.get(split_config, :type, :mini_swarm)

      enemy_config = Explore.Game.Config.Loader.get_enemy_config(config, type) || %{}

      for _ <- 1..count do
        new_enemy = EnemyConfig.to_enemy(type, enemy_config)
        # Start at same position but slightly behind
        offset = :rand.uniform() * 0.05

        %{
          new_enemy
          | path_progress: max(0, enemy.path_progress - offset),
            position: enemy.position
        }
      end
    else
      []
    end
  end

  # Check if any enemies reached the end
  defp check_enemies_reached_end(%World{} = world) do
    {reached_end, still_walking} =
      world.enemies
      |> Map.values()
      |> Enum.split_with(fn enemy -> enemy.path_progress >= 1.0 end)

    # Lose lives for each enemy that reached the end
    world_after_lives =
      Enum.reduce(reached_end, world, fn _enemy, acc ->
        {new_world, _game_over} = World.lose_life(acc)
        new_world
      end)

    # Remove enemies that reached the end
    %{world_after_lives | enemies: Map.new(still_walking, fn e -> {e.id, e} end)}
  end
end
