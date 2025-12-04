defmodule Explore.Game.Config.TowerConfig do
  @moduledoc """
  Tower configuration schema and validation.

  Defines the structure and validates tower configurations
  loaded from YAML files.
  """

  alias Explore.Game.Entities.Tower

  @valid_damage_types [:physical, :fire, :ice, :lightning, :poison]
  @valid_targeting [:first, :last, :closest, :strongest, :weakest]

  @doc """
  Validates a tower configuration map.
  Returns {:ok, config} or {:error, reasons}.
  """
  @spec validate(map()) :: {:ok, map()} | {:error, list(String.t())}
  def validate(config) when is_map(config) do
    errors = []

    errors = if Map.has_key?(config, :name), do: errors, else: ["missing :name" | errors]
    errors = if Map.has_key?(config, :cost), do: errors, else: ["missing :cost" | errors]
    errors = if Map.has_key?(config, :stats), do: errors, else: ["missing :stats" | errors]

    errors = validate_stats(config, errors)
    errors = validate_targeting(config, errors)
    errors = validate_effects(config, errors)

    if Enum.empty?(errors) do
      {:ok, normalize_config(config)}
    else
      {:error, errors}
    end
  end

  @doc """
  Creates a Tower struct from a configuration map.
  """
  @spec to_tower(atom(), {number(), number()}, map()) :: Tower.t()
  def to_tower(type, position, config) do
    Tower.new(type, position, normalize_config(config))
  end

  @doc """
  Gets the list of valid damage types.
  """
  @spec valid_damage_types() :: list(atom())
  def valid_damage_types, do: @valid_damage_types

  @doc """
  Gets the list of valid targeting strategies.
  """
  @spec valid_targeting_strategies() :: list(atom())
  def valid_targeting_strategies, do: @valid_targeting

  defp validate_stats(config, errors) do
    stats = Map.get(config, :stats, %{})

    errors =
      if Map.has_key?(stats, :damage) and is_number(Map.get(stats, :damage)) do
        errors
      else
        ["stats.damage must be a number" | errors]
      end

    errors =
      if Map.has_key?(stats, :range) and is_number(Map.get(stats, :range)) do
        errors
      else
        ["stats.range must be a number" | errors]
      end

    damage_type = Map.get(stats, :damage_type)

    errors =
      if damage_type == nil or to_atom(damage_type) in @valid_damage_types do
        errors
      else
        ["invalid damage_type: #{inspect(damage_type)}" | errors]
      end

    errors
  end

  defp validate_targeting(config, errors) do
    targeting = Map.get(config, :targeting)

    if targeting == nil or to_atom(targeting) in @valid_targeting do
      errors
    else
      ["invalid targeting: #{inspect(targeting)}" | errors]
    end
  end

  defp validate_effects(config, errors) do
    effects = Map.get(config, :effects, [])

    if is_list(effects) do
      effects
      |> Enum.with_index()
      |> Enum.reduce(errors, fn {effect, idx}, acc ->
        if Map.has_key?(effect, :type) and Map.has_key?(effect, :duration) do
          acc
        else
          ["effect at index #{idx} missing :type or :duration" | acc]
        end
      end)
    else
      ["effects must be a list" | errors]
    end
  end

  defp normalize_config(config) do
    stats = Map.get(config, :stats, %{})

    normalized_stats =
      stats
      |> Map.update(:damage_type, :physical, &to_atom/1)
      |> Map.put_new(:damage, 10)
      |> Map.put_new(:range, 100)
      |> Map.put_new(:fire_rate, 1.0)
      |> Map.put_new(:projectile_speed, 300)

    visual = Map.get(config, :visual, %{})

    normalized_visual =
      visual
      |> Map.update(:projectile_type, :arrow, &to_atom/1)

    config
    |> Map.put(:stats, normalized_stats)
    |> Map.put(:visual, normalized_visual)
    |> Map.update(:targeting, :first, &to_atom/1)
    |> Map.update(:effects, [], fn effects ->
      Enum.map(effects, fn effect ->
        Map.update(effect, :type, :slow, &to_atom/1)
      end)
    end)
  end

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_atom(value)
end
