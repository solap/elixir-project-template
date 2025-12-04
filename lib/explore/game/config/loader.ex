defmodule Explore.Game.Config.Loader do
  @moduledoc """
  Loads game configuration from YAML files.

  Configuration files are stored in priv/game_config/ and include:
  - towers.yml - Tower definitions
  - enemies.yml - Enemy definitions
  - tech_tree.yml - Tech tree structure
  - maps/*.yml - Map definitions
  - levels/*.yml - Level/wave definitions
  """

  @doc """
  Loads a YAML configuration file by name.
  Returns {:ok, config} or {:error, reason}.
  """
  @spec load(String.t()) :: {:ok, map()} | {:error, term()}
  def load(filename) do
    path = Path.join([config_path(), filename])

    case File.read(path) do
      {:ok, content} ->
        case YamlElixir.read_from_string(content) do
          {:ok, data} -> {:ok, atomize_keys(data)}
          {:error, reason} -> {:error, {:parse_error, reason}}
        end

      {:error, reason} ->
        {:error, {:file_error, reason}}
    end
  end

  @doc """
  Loads a configuration file, raising on error.
  """
  @spec load!(String.t()) :: map()
  def load!(filename) do
    case load(filename) do
      {:ok, config} -> config
      {:error, reason} -> raise "Failed to load config #{filename}: #{inspect(reason)}"
    end
  end

  @doc """
  Loads all game configuration files.
  Returns a map with :towers, :enemies, :tech_tree keys.
  """
  @spec load_all() :: {:ok, map()} | {:error, term()}
  def load_all do
    with {:ok, towers} <- load("towers.yml"),
         {:ok, enemies} <- load("enemies.yml"),
         {:ok, tech_tree} <- load("tech_tree.yml") do
      {:ok,
       %{
         towers: Map.get(towers, :towers, %{}),
         enemies: Map.get(enemies, :enemies, %{}),
         tech_tree: Map.get(tech_tree, :tech_tree, %{})
       }}
    end
  end

  @doc """
  Loads all configuration, raising on error.
  """
  @spec load_all!() :: map()
  def load_all! do
    case load_all() do
      {:ok, config} -> config
      {:error, reason} -> raise "Failed to load all configs: #{inspect(reason)}"
    end
  end

  @doc """
  Loads a map configuration.
  """
  @spec load_map(String.t()) :: {:ok, map()} | {:error, term()}
  def load_map(map_name) do
    load("maps/#{map_name}.yml")
  end

  @doc """
  Loads a level configuration.
  """
  @spec load_level(String.t()) :: {:ok, map()} | {:error, term()}
  def load_level(level_name) do
    load("levels/#{level_name}.yml")
  end

  @doc """
  Gets a tower configuration by type.
  """
  @spec get_tower_config(map(), atom()) :: map() | nil
  def get_tower_config(config, tower_type) do
    tower_type_key = if is_atom(tower_type), do: tower_type, else: String.to_atom(tower_type)
    get_in(config, [:towers, tower_type_key])
  end

  @doc """
  Gets an enemy configuration by type.
  """
  @spec get_enemy_config(map(), atom()) :: map() | nil
  def get_enemy_config(config, enemy_type) do
    enemy_type_key = if is_atom(enemy_type), do: enemy_type, else: String.to_atom(enemy_type)
    get_in(config, [:enemies, enemy_type_key])
  end

  # Recursively converts string keys to atoms
  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      key = if is_binary(k), do: String.to_atom(k), else: k
      {key, atomize_keys(v)}
    end)
  end

  defp atomize_keys(list) when is_list(list) do
    Enum.map(list, &atomize_keys/1)
  end

  defp atomize_keys(value), do: value

  # Get the config path - works in both dev and release modes
  defp config_path do
    Application.app_dir(:explore, "priv/game_config")
  end
end
