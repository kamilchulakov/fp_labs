defmodule Trie.NodeSet do
  @moduledoc """
  ### Operations
  - find(set, predicate)
  - filter(set, predicate)
  - foldl(set, acc, fun)
  """

  defp add_if([], x, predicate) do
    case predicate.(x) do
      true -> [x]
      false -> []
    end
  end

  defp add_if([set], x, predicate) do
    case predicate.(x) do
      true -> [set, x]
      false -> [set]
    end
  end

  def foldl([], acc, _), do: acc
  def foldl([head | tail], acc, fun), do: foldl(tail, fun.(head, acc), fun)

  def find([], _), do: nil

  def find(set, predicate) do
    [first, _] = filter(set, predicate)
    first
  end

  def filter([], _), do: []

  def filter(set, predicate) do
    foldl(set, [], &add_if(&2, &1, predicate))
  end
end
