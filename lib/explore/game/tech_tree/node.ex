defmodule Explore.Game.TechTree.Node do
  @moduledoc """
  Individual tech tree node.

  A node unlocks tower types and may require other nodes to be unlocked first.
  """

  @type t :: %__MODULE__{
          id: atom(),
          name: String.t(),
          description: String.t(),
          unlocks: list(atom()),
          requirements: list(atom()),
          cost: non_neg_integer()
        }

  defstruct id: nil,
            name: "",
            description: "",
            unlocks: [],
            requirements: [],
            cost: 0

  @doc """
  Creates a new node from a configuration map.
  """
  @spec new(atom(), map()) :: t()
  def new(id, config) do
    %__MODULE__{
      id: id,
      name: Map.get(config, :name, to_string(id)),
      description: Map.get(config, :description, ""),
      unlocks: config |> Map.get(:unlocks, []) |> Enum.map(&to_atom/1),
      requirements: config |> Map.get(:requirements, []) |> Enum.map(&to_atom/1),
      cost: Map.get(config, :cost, 0)
    }
  end

  defp to_atom(value) when is_atom(value), do: value
  defp to_atom(value) when is_binary(value), do: String.to_atom(value)

  @doc """
  Checks if a node can be unlocked given a set of already unlocked nodes.
  """
  @spec can_unlock?(t(), MapSet.t()) :: boolean()
  def can_unlock?(%__MODULE__{requirements: requirements}, unlocked_nodes) do
    Enum.all?(requirements, fn req -> MapSet.member?(unlocked_nodes, req) end)
  end

  @doc """
  Gets the tower types unlocked by this node.
  """
  @spec towers(t()) :: list(atom())
  def towers(%__MODULE__{unlocks: unlocks}), do: unlocks
end
