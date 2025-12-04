defmodule Explore.Game.WorldTest do
  use ExUnit.Case, async: true

  alias Explore.Game.World
  alias Explore.Game.Entities.{Tower, Enemy}

  describe "new/1" do
    test "creates world with default values" do
      world = World.new()

      assert world.resources == 500
      assert world.lives == 20
      assert world.state == :waiting
      assert world.tick == 0
    end

    test "creates world with custom values" do
      world = World.new(resources: 1000, lives: 10, total_waves: 5)

      assert world.resources == 1000
      assert world.lives == 10
      assert world.total_waves == 5
    end
  end

  describe "add_tower/2" do
    test "adds tower to world" do
      world = World.new()
      tower = Tower.new(:arrow_tower, {100, 100})

      updated = World.add_tower(world, tower)

      assert Map.has_key?(updated.towers, tower.id)
      assert updated.towers[tower.id] == tower
    end
  end

  describe "remove_tower/3" do
    test "removes tower and refunds resources" do
      tower = %{Tower.new(:arrow_tower, {100, 100}) | cost: 100}
      world = %{World.new() | towers: %{tower.id => tower}}

      updated = World.remove_tower(world, tower.id, 0.5)

      refute Map.has_key?(updated.towers, tower.id)
      assert updated.resources == 550
    end

    test "does nothing for non-existent tower" do
      world = World.new()
      updated = World.remove_tower(world, "nonexistent")

      assert updated == world
    end
  end

  describe "add_enemy/2" do
    test "adds enemy to world" do
      world = World.new()
      enemy = Enemy.new(:grunt)

      updated = World.add_enemy(world, enemy)

      assert Map.has_key?(updated.enemies, enemy.id)
    end
  end

  describe "spend_resources/2" do
    test "deducts resources when affordable" do
      world = World.new(resources: 500)

      assert {:ok, updated} = World.spend_resources(world, 100)
      assert updated.resources == 400
    end

    test "returns error when not affordable" do
      world = World.new(resources: 50)

      assert {:error, :insufficient_resources} = World.spend_resources(world, 100)
    end
  end

  describe "add_resources/2" do
    test "adds resources" do
      world = World.new(resources: 100)
      updated = World.add_resources(world, 50)

      assert updated.resources == 150
    end
  end

  describe "lose_life/1" do
    test "decrements lives" do
      world = World.new(lives: 10)
      {updated, game_over} = World.lose_life(world)

      assert updated.lives == 9
      refute game_over
    end

    test "returns game_over when lives reach 0" do
      world = World.new(lives: 1)
      {updated, game_over} = World.lose_life(world)

      assert updated.lives == 0
      assert game_over
      assert updated.state == :lost
    end
  end

  describe "next_wave/1" do
    test "increments wave number" do
      world = World.new()
      updated = World.next_wave(world)

      assert updated.current_wave == 1
    end

    test "sets state to won when all waves complete" do
      world = %{World.new(total_waves: 5) | current_wave: 4}
      updated = World.next_wave(world)

      assert updated.current_wave == 5
      assert updated.state == :won
    end
  end

  describe "tick/1" do
    test "increments tick counter" do
      world = World.new()
      updated = World.tick(world)

      assert updated.tick == 1
    end
  end

  describe "set_state/2" do
    test "updates game state" do
      world = World.new()
      updated = World.set_state(world, :playing)

      assert updated.state == :playing
    end
  end
end
