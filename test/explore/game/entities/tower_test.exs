defmodule Explore.Game.Entities.TowerTest do
  use ExUnit.Case, async: true

  alias Explore.Game.Entities.Tower

  describe "new/3" do
    test "creates a tower with default values" do
      tower = Tower.new(:arrow_tower, {100, 100})

      assert tower.type == :arrow_tower
      assert tower.position == {100, 100}
      assert is_binary(tower.id)
    end

    test "creates a tower with custom config" do
      config = %{
        name: "Test Tower",
        cost: 500,
        stats: %{
          damage: 50,
          range: 200,
          fire_rate: 2.0
        }
      }

      tower = Tower.new(:test_tower, {50, 50}, config)

      assert tower.name == "Test Tower"
      assert tower.cost == 500
      assert tower.stats.damage == 50
      assert tower.stats.range == 200
      assert tower.stats.fire_rate == 2.0
    end
  end

  describe "can_fire?/1" do
    test "returns true when cooldown is 0" do
      tower = Tower.new(:arrow_tower, {0, 0})
      assert Tower.can_fire?(tower)
    end

    test "returns false when cooldown is positive" do
      tower = %{Tower.new(:arrow_tower, {0, 0}) | cooldown: 0.5}
      refute Tower.can_fire?(tower)
    end
  end

  describe "reset_cooldown/1" do
    test "sets cooldown based on fire rate" do
      tower = Tower.new(:arrow_tower, {0, 0}, %{stats: %{fire_rate: 2.0}})
      tower_after = Tower.reset_cooldown(tower)

      assert tower_after.cooldown == 0.5
    end
  end

  describe "update_cooldown/2" do
    test "reduces cooldown by delta" do
      tower = %{Tower.new(:arrow_tower, {0, 0}) | cooldown: 1.0}
      tower_after = Tower.update_cooldown(tower, 0.3)

      assert_in_delta tower_after.cooldown, 0.7, 0.001
    end

    test "does not go below 0" do
      tower = %{Tower.new(:arrow_tower, {0, 0}) | cooldown: 0.2}
      tower_after = Tower.update_cooldown(tower, 0.5)

      assert tower_after.cooldown == 0
    end
  end

  describe "range/1" do
    test "returns the tower range" do
      tower = Tower.new(:arrow_tower, {0, 0}, %{stats: %{range: 150}})
      assert Tower.range(tower) == 150
    end
  end

  describe "in_range?/2" do
    test "returns true for position within range" do
      tower = Tower.new(:arrow_tower, {100, 100}, %{stats: %{range: 100}})
      assert Tower.in_range?(tower, {150, 100})
    end

    test "returns false for position outside range" do
      tower = Tower.new(:arrow_tower, {100, 100}, %{stats: %{range: 50}})
      refute Tower.in_range?(tower, {200, 100})
    end
  end

  describe "distance_to/2" do
    test "calculates correct distance" do
      tower = Tower.new(:arrow_tower, {0, 0})
      distance = Tower.distance_to(tower, {3, 4})

      assert_in_delta distance, 5.0, 0.001
    end
  end

  describe "has_aoe?/1" do
    test "returns true when aoe_radius is set" do
      tower = Tower.new(:flame_tower, {0, 0}, %{stats: %{aoe_radius: 50}})
      assert Tower.has_aoe?(tower)
    end

    test "returns false when aoe_radius is nil" do
      tower = Tower.new(:arrow_tower, {0, 0})
      refute Tower.has_aoe?(tower)
    end
  end
end
