defmodule Explore.Game.Config.WaveConfig do
  @moduledoc """
  Wave/level configuration schema and validation.

  Defines the structure for wave configurations
  loaded from level YAML files.
  """

  @doc """
  Validates a level configuration map.
  Returns {:ok, config} or {:error, reasons}.
  """
  @spec validate(map()) :: {:ok, map()} | {:error, list(String.t())}
  def validate(config) when is_map(config) do
    level = Map.get(config, :level, config)
    errors = []

    errors = if Map.has_key?(level, :name), do: errors, else: ["missing :name" | errors]
    errors = if Map.has_key?(level, :waves), do: errors, else: ["missing :waves" | errors]

    errors = validate_waves(level, errors)

    if Enum.empty?(errors) do
      {:ok, normalize_config(level)}
    else
      {:error, errors}
    end
  end

  @doc """
  Gets the wave count from a level configuration.
  """
  @spec wave_count(map()) :: non_neg_integer()
  def wave_count(config) do
    config
    |> Map.get(:waves, [])
    |> length()
  end

  @doc """
  Gets a specific wave from the configuration.
  """
  @spec get_wave(map(), non_neg_integer()) :: map() | nil
  def get_wave(config, wave_number) do
    waves = Map.get(config, :waves, [])
    Enum.find(waves, fn w -> Map.get(w, :number) == wave_number end)
  end

  defp validate_waves(config, errors) do
    waves = Map.get(config, :waves, [])

    if is_list(waves) do
      waves
      |> Enum.with_index(1)
      |> Enum.reduce(errors, fn {wave, idx}, acc ->
        validate_wave(wave, idx, acc)
      end)
    else
      ["waves must be a list" | errors]
    end
  end

  defp validate_wave(wave, idx, errors) do
    errors =
      if Map.has_key?(wave, :enemies) do
        errors
      else
        ["wave #{idx} missing :enemies" | errors]
      end

    enemies = Map.get(wave, :enemies, [])

    if is_list(enemies) do
      enemies
      |> Enum.with_index()
      |> Enum.reduce(errors, fn {enemy_group, eidx}, acc ->
        validate_enemy_group(enemy_group, idx, eidx, acc)
      end)
    else
      ["wave #{idx} enemies must be a list" | errors]
    end
  end

  defp validate_enemy_group(group, wave_idx, group_idx, errors) do
    errors =
      if Map.has_key?(group, :type) do
        errors
      else
        ["wave #{wave_idx} enemy group #{group_idx} missing :type" | errors]
      end

    errors =
      if Map.has_key?(group, :count) do
        errors
      else
        ["wave #{wave_idx} enemy group #{group_idx} missing :count" | errors]
      end

    errors
  end

  defp normalize_config(config) do
    config
    |> Map.put_new(:starting_resources, 500)
    |> Map.put_new(:starting_lives, 20)
    |> Map.update(:waves, [], fn waves ->
      Enum.map(waves, &normalize_wave/1)
    end)
  end

  defp normalize_wave(wave) do
    wave
    |> Map.put_new(:delay_after, 5000)
    |> Map.update(:enemies, [], fn enemies ->
      Enum.map(enemies, &normalize_enemy_group/1)
    end)
  end

  defp normalize_enemy_group(group) do
    group
    |> Map.update(:type, :grunt, &to_atom/1)
    |> Map.put_new(:count, 1)
    |> Map.put_new(:interval, 1000)
  end

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_atom(value)
end
