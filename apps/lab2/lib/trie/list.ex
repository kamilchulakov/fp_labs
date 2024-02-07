defmodule Trie.List do
  @moduledoc """
  ### Operations
  - find(list, predicate)
  - filter(list, predicate)
  - foldl(list, acc, fun)
  - map(list, mapper)
  - map_if(list, predicate, mapper)
  - merge(list, other)
  """

  def foldl([], acc, _), do: acc
  def foldl([head | tail], acc, fun), do: foldl(tail, fun.(head, acc), fun)

  def foldr([], acc, _), do: acc
  def foldr([head | tail], acc, fun), do: fun.(head, foldr(tail, acc, fun))

  def find([], _), do: nil

  def find(set, predicate) do
    [first | _] = filter(set, predicate)
    first
  end

  def filter([], _), do: []

  def filter(set, predicate) do
    foldl(set, [], &add_if(&2, &1, predicate))
  end

  def map_if([], _, _), do: []

  def map_if([head | tail], predicate, mapper) do
    fun = fn x, acc ->
      case predicate.(x) do
        true -> [mapper.(x) | acc]
        _ -> acc
      end
    end

    foldl(tail, fun.(head, []), fun)
  end

  def map(list, mapper), do: foldl(list, [], &(&2 ++ [mapper.(&1)]))

  def merge(list, other), do: list ++ other

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
end
