defmodule Explore.Game.Config.TechTreeConfig do
  @moduledoc """
  Tech tree configuration schema and validation.

  Defines the structure for tech tree configurations
  loaded from YAML files.
  """

  @doc """
  Validates a tech tree configuration map.
  Returns {:ok, config} or {:error, reasons}.
  """
  @spec validate(map()) :: {:ok, map()} | {:error, list(String.t())}
  def validate(config) when is_map(config) do
    tech_tree = Map.get(config, :tech_tree, config)
    errors = []

    errors = if Map.has_key?(tech_tree, :nodes), do: errors, else: ["missing :nodes" | errors]

    errors = validate_nodes(tech_tree, errors)
    errors = validate_starting_unlocked(tech_tree, errors)

    if Enum.empty?(errors) do
      {:ok, normalize_config(tech_tree)}
    else
      {:error, errors}
    end
  end

  @doc """
  Gets a node by its ID.
  """
  @spec get_node(map(), atom()) :: map() | nil
  def get_node(config, node_id) do
    get_in(config, [:nodes, node_id])
  end

  @doc """
  Gets the list of starting unlocked node IDs.
  """
  @spec starting_unlocked(map()) :: list(atom())
  def starting_unlocked(config) do
    Map.get(config, :starting_unlocked, [])
  end

  @doc """
  Gets all tower types unlocked by a node.
  """
  @spec unlocked_towers(map(), atom()) :: list(atom())
  def unlocked_towers(config, node_id) do
    node = get_node(config, node_id)
    if node, do: Map.get(node, :unlocks, []), else: []
  end

  @doc """
  Gets the requirements for a node.
  """
  @spec node_requirements(map(), atom()) :: list(atom())
  def node_requirements(config, node_id) do
    node = get_node(config, node_id)
    if node, do: Map.get(node, :requirements, []), else: []
  end

  @doc """
  Gets the cost to unlock a node.
  """
  @spec node_cost(map(), atom()) :: non_neg_integer()
  def node_cost(config, node_id) do
    node = get_node(config, node_id)
    if node, do: Map.get(node, :cost, 0), else: 0
  end

  defp validate_nodes(config, errors) do
    nodes = Map.get(config, :nodes, %{})

    if is_map(nodes) do
      Enum.reduce(nodes, errors, fn {node_id, node}, acc ->
        validate_node(node_id, node, acc)
      end)
    else
      ["nodes must be a map" | errors]
    end
  end

  defp validate_node(node_id, node, errors) do
    errors =
      if Map.has_key?(node, :name) do
        errors
      else
        ["node #{node_id} missing :name" | errors]
      end

    errors =
      if Map.has_key?(node, :unlocks) and is_list(Map.get(node, :unlocks)) do
        errors
      else
        ["node #{node_id} missing or invalid :unlocks" | errors]
      end

    errors
  end

  defp validate_starting_unlocked(config, errors) do
    starting = Map.get(config, :starting_unlocked, [])
    nodes = Map.get(config, :nodes, %{})

    if is_list(starting) do
      invalid =
        starting
        |> Enum.map(&to_atom/1)
        |> Enum.reject(fn node_id -> Map.has_key?(nodes, node_id) end)

      if Enum.empty?(invalid) do
        errors
      else
        ["starting_unlocked references unknown nodes: #{inspect(invalid)}" | errors]
      end
    else
      ["starting_unlocked must be a list" | errors]
    end
  end

  defp normalize_config(config) do
    config
    |> Map.update(:nodes, %{}, fn nodes ->
      Map.new(nodes, fn {k, v} ->
        {to_atom(k), normalize_node(v)}
      end)
    end)
    |> Map.update(:starting_unlocked, [], fn list ->
      Enum.map(list, &to_atom/1)
    end)
  end

  defp normalize_node(node) do
    node
    |> Map.put_new(:cost, 0)
    |> Map.put_new(:description, "")
    |> Map.update(:unlocks, [], fn list -> Enum.map(list, &to_atom/1) end)
    |> Map.update(:requirements, [], fn list -> Enum.map(list, &to_atom/1) end)
  end

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_atom(value)
end
