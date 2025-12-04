defmodule Explore.Game.TechTree.Tree do
  @moduledoc """
  Tech tree structure and unlocking logic.

  The tech tree controls which towers are available to the player.
  """

  alias Explore.Game.TechTree.Node
  alias Explore.Game.Config.TechTreeConfig

  @type t :: %__MODULE__{
          nodes: %{atom() => Node.t()},
          unlocked: MapSet.t(),
          points: non_neg_integer()
        }

  defstruct nodes: %{},
            unlocked: MapSet.new(),
            points: 0

  @doc """
  Creates a new tech tree from game configuration.
  """
  @spec new(map()) :: t()
  def new(config) do
    tech_tree_config = Map.get(config, :tech_tree, %{})

    nodes =
      tech_tree_config
      |> Map.get(:nodes, %{})
      |> Enum.map(fn {id, node_config} ->
        {id, Node.new(id, node_config)}
      end)
      |> Map.new()

    starting_unlocked =
      tech_tree_config
      |> TechTreeConfig.starting_unlocked()
      |> Enum.map(&to_atom/1)
      |> MapSet.new()

    %__MODULE__{
      nodes: nodes,
      unlocked: starting_unlocked,
      points: 0
    }
  end

  @doc """
  Checks if a node is unlocked.
  """
  @spec node_unlocked?(t(), atom()) :: boolean()
  def node_unlocked?(%__MODULE__{unlocked: unlocked}, node_id) do
    MapSet.member?(unlocked, node_id)
  end

  @doc """
  Checks if a node can be unlocked (requirements met).
  """
  @spec can_unlock_node?(t(), atom()) :: boolean()
  def can_unlock_node?(%__MODULE__{nodes: nodes, unlocked: unlocked}, node_id) do
    case Map.get(nodes, node_id) do
      nil -> false
      node -> not MapSet.member?(unlocked, node_id) and Node.can_unlock?(node, unlocked)
    end
  end

  @doc """
  Unlocks a node if requirements are met and player has enough points.
  Returns {:ok, updated_tree} or {:error, reason}.
  """
  @spec unlock_node(t(), atom()) :: {:ok, t()} | {:error, atom()}
  def unlock_node(%__MODULE__{nodes: nodes, unlocked: unlocked, points: points} = tree, node_id) do
    case Map.get(nodes, node_id) do
      nil ->
        {:error, :unknown_node}

      node ->
        cond do
          MapSet.member?(unlocked, node_id) ->
            {:error, :already_unlocked}

          not Node.can_unlock?(node, unlocked) ->
            {:error, :requirements_not_met}

          points < node.cost ->
            {:error, :insufficient_points}

          true ->
            {:ok,
             %{
               tree
               | unlocked: MapSet.put(unlocked, node_id),
                 points: points - node.cost
             }}
        end
    end
  end

  @doc """
  Adds points to the tech tree.
  """
  @spec add_points(t(), non_neg_integer()) :: t()
  def add_points(%__MODULE__{points: points} = tree, amount) do
    %{tree | points: points + amount}
  end

  @doc """
  Gets all currently available towers (from unlocked nodes).
  """
  @spec available_towers(t()) :: list(atom())
  def available_towers(%__MODULE__{nodes: nodes, unlocked: unlocked}) do
    unlocked
    |> Enum.flat_map(fn node_id ->
      case Map.get(nodes, node_id) do
        nil -> []
        node -> Node.towers(node)
      end
    end)
    |> Enum.uniq()
  end

  @doc """
  Checks if a specific tower type is available.
  """
  @spec tower_available?(t(), atom()) :: boolean()
  def tower_available?(%__MODULE__{} = tree, tower_type) do
    tower_type in available_towers(tree)
  end

  @doc """
  Gets nodes that can currently be unlocked.
  """
  @spec available_to_unlock(t()) :: list(atom())
  def available_to_unlock(%__MODULE__{nodes: nodes, unlocked: unlocked}) do
    nodes
    |> Map.keys()
    |> Enum.filter(fn node_id ->
      not MapSet.member?(unlocked, node_id) and
        Node.can_unlock?(Map.get(nodes, node_id), unlocked)
    end)
  end

  @doc """
  Gets all node IDs in the tree.
  """
  @spec all_nodes(t()) :: list(atom())
  def all_nodes(%__MODULE__{nodes: nodes}) do
    Map.keys(nodes)
  end

  @doc """
  Gets a node by ID.
  """
  @spec get_node(t(), atom()) :: Node.t() | nil
  def get_node(%__MODULE__{nodes: nodes}, node_id) do
    Map.get(nodes, node_id)
  end

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_atom(value)
end
