defmodule Explore.Game.Config.LoaderTest do
  use ExUnit.Case, async: true

  alias Explore.Game.Config.Loader

  describe "load/1" do
    test "loads towers.yml successfully" do
      assert {:ok, config} = Loader.load("towers.yml")
      assert Map.has_key?(config, :towers)
      assert Map.has_key?(config.towers, :arrow_tower)
    end

    test "loads enemies.yml successfully" do
      assert {:ok, config} = Loader.load("enemies.yml")
      assert Map.has_key?(config, :enemies)
      assert Map.has_key?(config.enemies, :grunt)
    end

    test "loads tech_tree.yml successfully" do
      assert {:ok, config} = Loader.load("tech_tree.yml")
      assert Map.has_key?(config, :tech_tree)
      assert Map.has_key?(config.tech_tree, :nodes)
    end

    test "returns error for non-existent file" do
      assert {:error, {:file_error, _}} = Loader.load("nonexistent.yml")
    end
  end

  describe "load_all/0" do
    test "loads all config files" do
      assert {:ok, config} = Loader.load_all()

      assert Map.has_key?(config, :towers)
      assert Map.has_key?(config, :enemies)
      assert Map.has_key?(config, :tech_tree)
    end
  end

  describe "load_level/1" do
    test "loads level configuration" do
      assert {:ok, config} = Loader.load_level("level_01")
      assert Map.has_key?(config, :level)
    end
  end

  describe "get_tower_config/2" do
    test "returns tower config by type" do
      {:ok, config} = Loader.load_all()
      tower = Loader.get_tower_config(config, :arrow_tower)

      assert tower != nil
      assert Map.has_key?(tower, :name)
      assert Map.has_key?(tower, :cost)
    end

    test "returns nil for unknown tower" do
      {:ok, config} = Loader.load_all()
      assert Loader.get_tower_config(config, :nonexistent) == nil
    end
  end

  describe "get_enemy_config/2" do
    test "returns enemy config by type" do
      {:ok, config} = Loader.load_all()
      enemy = Loader.get_enemy_config(config, :grunt)

      assert enemy != nil
      assert Map.has_key?(enemy, :name)
      assert Map.has_key?(enemy, :health)
    end

    test "returns nil for unknown enemy" do
      {:ok, config} = Loader.load_all()
      assert Loader.get_enemy_config(config, :nonexistent) == nil
    end
  end
end
