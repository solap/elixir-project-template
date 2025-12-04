defmodule Explore.Game.Combat.DamageTest do
  use ExUnit.Case, async: true

  alias Explore.Game.Combat.Damage
  alias Explore.Game.Entities.Enemy

  describe "calculate_damage/3" do
    test "returns base damage with no resistances" do
      enemy = Enemy.new(:grunt)
      damage = Damage.calculate_damage(100, :physical, enemy)

      assert damage == 100
    end

    test "reduces damage based on resistance" do
      enemy = Enemy.new(:tank, %{resistances: %{physical: 0.3}})
      damage = Damage.calculate_damage(100, :physical, enemy)

      assert_in_delta damage, 70, 0.01
    end

    test "increases damage based on weakness" do
      enemy = Enemy.new(:ice_golem, %{weaknesses: %{fire: 0.5}})
      damage = Damage.calculate_damage(100, :fire, enemy)

      assert_in_delta damage, 150, 0.01
    end

    test "combines resistance and weakness" do
      enemy = Enemy.new(:elemental, %{resistances: %{fire: 0.2}, weaknesses: %{ice: 0.3}})
      fire_damage = Damage.calculate_damage(100, :fire, enemy)
      ice_damage = Damage.calculate_damage(100, :ice, enemy)

      assert_in_delta fire_damage, 80, 0.01
      assert_in_delta ice_damage, 130, 0.01
    end

    test "never returns negative damage" do
      enemy = Enemy.new(:immune, %{resistances: %{physical: 1.5}})
      damage = Damage.calculate_damage(100, :physical, enemy)

      assert damage == 0
    end
  end

  describe "apply_damage/3" do
    test "applies damage and returns updated enemy" do
      enemy = Enemy.new(:grunt, %{health: 100})
      {updated, actual} = Damage.apply_damage(enemy, 30, :physical)

      assert updated.health == 70
      assert actual == 30
    end
  end

  describe "calculate_aoe_damage/5" do
    test "damages enemies within radius" do
      enemy1 = %{Enemy.new(:grunt) | id: "e1", position: {100, 100}}
      enemy2 = %{Enemy.new(:grunt) | id: "e2", position: {110, 100}}
      enemy3 = %{Enemy.new(:grunt) | id: "e3", position: {200, 200}}

      center = {100, 100}
      radius = 50
      enemies = [enemy1, enemy2, enemy3]

      damages = Damage.calculate_aoe_damage(100, :physical, center, radius, enemies)

      # Only enemies within radius should be damaged
      assert length(damages) == 2
      assert Enum.any?(damages, fn {id, _} -> id == "e1" end)
      assert Enum.any?(damages, fn {id, _} -> id == "e2" end)
      refute Enum.any?(damages, fn {id, _} -> id == "e3" end)
    end

    test "applies damage falloff based on distance" do
      enemy_center = %{Enemy.new(:grunt) | id: "center", position: {100, 100}}
      enemy_edge = %{Enemy.new(:grunt) | id: "edge", position: {149, 100}}

      center = {100, 100}
      radius = 50
      enemies = [enemy_center, enemy_edge]

      damages = Damage.calculate_aoe_damage(100, :physical, center, radius, enemies)

      center_dmg = Enum.find_value(damages, fn {id, d} -> if id == "center", do: d end)
      edge_dmg = Enum.find_value(damages, fn {id, d} -> if id == "edge", do: d end)

      # Center enemy should take full damage
      assert_in_delta center_dmg, 100, 1
      # Edge enemy should take reduced damage
      assert edge_dmg < center_dmg
    end
  end

  describe "damage_type_color/1" do
    test "returns appropriate colors for each type" do
      assert Damage.damage_type_color(:physical) =~ "#"
      assert Damage.damage_type_color(:fire) =~ "#"
      assert Damage.damage_type_color(:ice) =~ "#"
      assert Damage.damage_type_color(:lightning) =~ "#"
      assert Damage.damage_type_color(:poison) =~ "#"
    end
  end
end
