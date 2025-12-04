defmodule Explore.Game.Entities.EnemyTest do
  use ExUnit.Case, async: true

  alias Explore.Game.Entities.Enemy
  alias Explore.Game.Combat.Effects

  describe "new/2" do
    test "creates an enemy with default values" do
      enemy = Enemy.new(:grunt)

      assert enemy.type == :grunt
      assert is_binary(enemy.id)
      assert enemy.health == 100
      assert enemy.max_health == 100
    end

    test "creates an enemy with custom config" do
      config = %{
        name: "Test Enemy",
        health: 500,
        speed: 30,
        reward: 50
      }

      enemy = Enemy.new(:tank, config)

      assert enemy.name == "Test Enemy"
      assert enemy.health == 500
      assert enemy.max_health == 500
      assert enemy.speed == 30
      assert enemy.reward == 50
    end
  end

  describe "take_damage/3" do
    test "reduces health by damage amount" do
      enemy = Enemy.new(:grunt, %{health: 100})
      {updated, actual_damage} = Enemy.take_damage(enemy, 30, :physical)

      assert updated.health == 70
      assert actual_damage == 30
    end

    test "accounts for resistances" do
      enemy = Enemy.new(:tank, %{health: 100, resistances: %{physical: 0.5}})
      {updated, actual_damage} = Enemy.take_damage(enemy, 30, :physical)

      assert updated.health == 85
      assert actual_damage == 15
    end

    test "accounts for weaknesses" do
      enemy = Enemy.new(:ice_golem, %{health: 100, weaknesses: %{fire: 0.5}})
      {updated, actual_damage} = Enemy.take_damage(enemy, 20, :fire)

      assert updated.health == 70
      assert actual_damage == 30
    end

    test "does not go below 0 health" do
      enemy = Enemy.new(:grunt, %{health: 10})
      {updated, _} = Enemy.take_damage(enemy, 50, :physical)

      assert updated.health == 0
    end
  end

  describe "dead?/1" do
    test "returns true when health is 0" do
      enemy = %{Enemy.new(:grunt) | health: 0}
      assert Enemy.dead?(enemy)
    end

    test "returns false when health is positive" do
      enemy = %{Enemy.new(:grunt) | health: 1}
      refute Enemy.dead?(enemy)
    end
  end

  describe "health_percentage/1" do
    test "returns correct percentage" do
      enemy = %{Enemy.new(:grunt, %{health: 100}) | health: 75}
      assert_in_delta Enemy.health_percentage(enemy), 0.75, 0.001
    end
  end

  describe "apply_effect/2" do
    test "adds new effect" do
      enemy = Enemy.new(:grunt)
      effect = Effects.slow(2000, 0.5)
      updated = Enemy.apply_effect(enemy, effect)

      assert length(updated.effects) == 1
      assert hd(updated.effects).type == :slow
    end

    test "updates existing effect with longer duration" do
      enemy = Enemy.new(:grunt)
      effect1 = Effects.slow(1000, 0.5)
      effect2 = Effects.slow(3000, 0.3)

      updated =
        enemy
        |> Enemy.apply_effect(effect1)
        |> Enemy.apply_effect(effect2)

      assert length(updated.effects) == 1
      assert hd(updated.effects).duration == 3000
    end
  end

  describe "has_effect?/2" do
    test "returns true when effect exists" do
      enemy = Enemy.new(:grunt) |> Enemy.apply_effect(Effects.slow(1000, 0.5))
      assert Enemy.has_effect?(enemy, :slow)
    end

    test "returns false when effect does not exist" do
      enemy = Enemy.new(:grunt)
      refute Enemy.has_effect?(enemy, :slow)
    end
  end

  describe "move/3" do
    test "increases path progress" do
      enemy = Enemy.new(:grunt, %{speed: 100})
      {updated, reached_end} = Enemy.move(enemy, 0.1, 1000)

      assert updated.path_progress > 0
      refute reached_end
    end

    test "returns true when reaching end" do
      enemy = %{Enemy.new(:grunt, %{speed: 100}) | path_progress: 0.99}
      {updated, reached_end} = Enemy.move(enemy, 1.0, 100)

      assert updated.path_progress == 1.0
      assert reached_end
    end
  end
end
