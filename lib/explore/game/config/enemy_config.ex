defmodule Explore.Game.Config.EnemyConfig do
  @moduledoc """
  Enemy configuration schema and validation.

  Defines the structure and validates enemy configurations
  loaded from YAML files.
  """

  alias Explore.Game.Entities.Enemy

  @valid_damage_types [:physical, :fire, :ice, :lightning, :poison]

  @doc """
  Validates an enemy configuration map.
  Returns {:ok, config} or {:error, reasons}.
  """
  @spec validate(map()) :: {:ok, map()} | {:error, list(String.t())}
  def validate(config) when is_map(config) do
    errors = []

    errors = if Map.has_key?(config, :name), do: errors, else: ["missing :name" | errors]
    errors = if Map.has_key?(config, :health), do: errors, else: ["missing :health" | errors]
    errors = if Map.has_key?(config, :speed), do: errors, else: ["missing :speed" | errors]

    errors = validate_resistances(config, errors)
    errors = validate_special(config, errors)

    if Enum.empty?(errors) do
      {:ok, normalize_config(config)}
    else
      {:error, errors}
    end
  end

  @doc """
  Creates an Enemy struct from a configuration map.
  """
  @spec to_enemy(atom(), map()) :: Enemy.t()
  def to_enemy(type, config) do
    Enemy.new(type, normalize_config(config))
  end

  defp validate_resistances(config, errors) do
    resistances = Map.get(config, :resistances, %{})

    if is_map(resistances) do
      invalid_types =
        resistances
        |> Map.keys()
        |> Enum.reject(fn key -> to_atom(key) in @valid_damage_types end)

      if Enum.empty?(invalid_types) do
        errors
      else
        ["invalid resistance types: #{inspect(invalid_types)}" | errors]
      end
    else
      ["resistances must be a map" | errors]
    end
  end

  defp validate_special(config, errors) do
    special = Map.get(config, :special)

    if special == nil or is_map(special) do
      errors
    else
      ["special must be a map" | errors]
    end
  end

  defp normalize_config(config) do
    config
    |> Map.put_new(:health, 100)
    |> Map.put_new(:speed, 50)
    |> Map.put_new(:reward, 10)
    |> Map.update(:resistances, %{}, &normalize_resistances/1)
    |> Map.update(:weaknesses, %{}, &normalize_resistances/1)
  end

  defp normalize_resistances(resistances) when is_map(resistances) do
    Map.new(resistances, fn {k, v} ->
      {to_atom(k), v}
    end)
  end

  defp normalize_resistances(_), do: %{}

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_atom(value)
end
