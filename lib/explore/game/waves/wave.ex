defmodule Explore.Game.Waves.Wave do
  @moduledoc """
  Wave definition struct.

  A wave consists of enemy groups that spawn over time.
  """

  @type enemy_group :: %{
          type: atom(),
          count: non_neg_integer(),
          interval: non_neg_integer()
        }

  @type wave_state :: :waiting | :spawning | :complete

  @type t :: %__MODULE__{
          number: non_neg_integer(),
          enemy_groups: list(enemy_group()),
          delay_after: non_neg_integer(),
          state: wave_state()
        }

  defstruct number: 1,
            enemy_groups: [],
            delay_after: 5000,
            state: :waiting

  @doc """
  Creates a new wave from a configuration map.
  """
  @spec new(map()) :: t()
  def new(config) do
    %__MODULE__{
      number: Map.get(config, :number, 1),
      enemy_groups: normalize_enemy_groups(Map.get(config, :enemies, [])),
      delay_after: Map.get(config, :delay_after, 5000),
      state: :waiting
    }
  end

  @doc """
  Gets the total number of enemies in the wave.
  """
  @spec total_enemies(t()) :: non_neg_integer()
  def total_enemies(%__MODULE__{enemy_groups: groups}) do
    Enum.reduce(groups, 0, fn group, acc -> acc + Map.get(group, :count, 0) end)
  end

  defp normalize_enemy_groups(groups) do
    Enum.map(groups, fn group ->
      %{
        type: to_atom(Map.get(group, :type, :grunt)),
        count: Map.get(group, :count, 1),
        interval: Map.get(group, :interval, 1000)
      }
    end)
  end

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_atom(value)
end
