defmodule Explore.Game.Map.Path do
  @moduledoc """
  Path definition and waypoint system for enemy movement.

  A path consists of waypoints that enemies follow from start to end.
  Progress is measured as a float from 0.0 (start) to 1.0 (end).
  """

  @type position :: {number(), number()}

  @type t :: %__MODULE__{
          waypoints: list(position()),
          segments: list({position(), position(), number()}),
          total_length: number()
        }

  defstruct waypoints: [],
            segments: [],
            total_length: 0

  @doc """
  Creates a new path from a list of waypoints.
  """
  @spec new(list(position()) | list(map())) :: t()
  def new(waypoints) when is_list(waypoints) do
    normalized_waypoints = normalize_waypoints(waypoints)
    segments = calculate_segments(normalized_waypoints)
    total_length = Enum.reduce(segments, 0, fn {_, _, len}, acc -> acc + len end)

    %__MODULE__{
      waypoints: normalized_waypoints,
      segments: segments,
      total_length: total_length
    }
  end

  @doc """
  Converts a path progress (0.0 to 1.0) to a world position.
  """
  @spec progress_to_position(t(), number()) :: position()
  def progress_to_position(%__MODULE__{segments: [], waypoints: [wp | _]}, _progress) do
    wp
  end

  def progress_to_position(%__MODULE__{} = path, progress) when progress <= 0.0 do
    List.first(path.waypoints) || {0, 0}
  end

  def progress_to_position(%__MODULE__{} = path, progress) when progress >= 1.0 do
    List.last(path.waypoints) || {0, 0}
  end

  def progress_to_position(%__MODULE__{} = path, progress) do
    target_distance = progress * path.total_length
    find_position_at_distance(path.segments, target_distance, 0)
  end

  @doc """
  Gets the total length of the path.
  """
  @spec length(t()) :: number()
  def length(%__MODULE__{total_length: len}), do: len

  @doc """
  Gets the start position of the path.
  """
  @spec start_position(t()) :: position()
  def start_position(%__MODULE__{waypoints: [first | _]}), do: first
  def start_position(_), do: {0, 0}

  @doc """
  Gets the end position of the path.
  """
  @spec end_position(t()) :: position()
  def end_position(%__MODULE__{waypoints: waypoints}) do
    List.last(waypoints) || {0, 0}
  end

  @doc """
  Interpolates between two positions.
  """
  @spec interpolate(position(), position(), number()) :: position()
  def interpolate({x1, y1}, {x2, y2}, t) do
    t = max(0, min(1, t))
    {x1 + (x2 - x1) * t, y1 + (y2 - y1) * t}
  end

  @doc """
  Calculates the direction (angle in radians) at a given progress.
  """
  @spec direction_at(t(), number()) :: number()
  def direction_at(%__MODULE__{segments: []}, _progress), do: 0.0

  def direction_at(%__MODULE__{} = path, progress) do
    target_distance = max(0, min(1, progress)) * path.total_length
    find_direction_at_distance(path.segments, target_distance, 0)
  end

  # Private functions

  defp normalize_waypoints(waypoints) do
    Enum.map(waypoints, fn
      {x, y} -> {x, y}
      %{x: x, y: y} -> {x, y}
      %{"x" => x, "y" => y} -> {x, y}
    end)
  end

  defp calculate_segments([]), do: []
  defp calculate_segments([_]), do: []

  defp calculate_segments(waypoints) do
    waypoints
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [p1, p2] ->
      {p1, p2, distance(p1, p2)}
    end)
  end

  defp distance({x1, y1}, {x2, y2}) do
    dx = x2 - x1
    dy = y2 - y1
    :math.sqrt(dx * dx + dy * dy)
  end

  defp find_position_at_distance([], _target, _accumulated) do
    {0, 0}
  end

  defp find_position_at_distance([{start_pos, end_pos, segment_len} | rest], target, accumulated) do
    if accumulated + segment_len >= target do
      # Position is within this segment
      local_progress = (target - accumulated) / segment_len
      interpolate(start_pos, end_pos, local_progress)
    else
      find_position_at_distance(rest, target, accumulated + segment_len)
    end
  end

  defp find_direction_at_distance([], _target, _accumulated), do: 0.0

  defp find_direction_at_distance([{{x1, y1}, {x2, y2}, segment_len} | rest], target, accumulated) do
    if accumulated + segment_len >= target do
      :math.atan2(y2 - y1, x2 - x1)
    else
      find_direction_at_distance(rest, target, accumulated + segment_len)
    end
  end
end
