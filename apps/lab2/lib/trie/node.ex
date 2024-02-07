defmodule Trie.Node do
  @moduledoc """
  Provides a node record with children set and is_end flag
  """
  alias Trie.List
  require Record

  Record.defrecord(:trie_node, x: nil, children: [], word: nil)

  @type trie_node :: record(:trie_node, x: any(), children: [trie_node], word: any())
  @type trie_node(x) :: record(:trie_node, x: x, children: [trie_node(x)], word: any())

  def insert(node, wordable, word) when trie_node(node, :x) == nil and is_list(wordable),
    do: trie_node(node, children: insert_child(children(node), wordable, word))

  def insert(node, [x], word) when trie_node(node, :x) == x and trie_node(node, :word) == nil,
    do: trie_node(node, word: word)

  def insert(node, [x], _) when trie_node(node, :x) == x and trie_node(node, :word) != nil,
    do: node

  def insert(node, [head | tail], word) when trie_node(node, :x) == head,
    do: trie_node(node, children: insert_child(children(node), tail, word))

  defp insert_child(children \\ [], wordable, word)

  defp insert_child([], [x], word), do: [word_node(x, word)]

  defp insert_child([head | tail], [x], word)
       when trie_node(head, :x) == x and trie_node(head, :word) == nil,
       do: [trie_node(head, word: word) | tail]

  defp insert_child(children = [head | _], [x], _)
       when trie_node(head, :x) == x and trie_node(head, :word) != nil do
    children
  end

  defp insert_child(children = [head | _], [x], word) when trie_node(head, :x) > x,
    do: [word_node(x, word) | children]

  defp insert_child([head | tail], [x], word) when trie_node(head, :x) != x,
    do: [head | insert_child(tail, [x], word)]

  defp insert_child([], [head | tail], word),
    do: [trie_node(x: head, children: insert_child(tail, word))]

  defp insert_child([head_child | tail_child], [head_x | tail_x], word)
       when trie_node(head_child, :x) == head_x,
       do: [insert(head_child, [head_x | tail_x], word) | tail_child]

  defp insert_child(children = [head_child | _], wordable = [head_x | _], word)
       when trie_node(head_child, :x) > head_x,
       do: [insert(trie_node(x: head_x), wordable, word) | children]

  defp insert_child([head_child | tail_child], [head_x | tail_x], word)
       when trie_node(head_child, :x) != head_x,
       do: [head_child | insert_child(tail_child, [head_x | tail_x], word)]

  def entries(node)
      when trie_node(node, :x) == nil,
      do: List.foldl(children(node), [], fn child, acc -> acc ++ search(child) end)

  def search(node, prefix \\ [])

  def search(node, prefix)
      when trie_node(node, :x) == nil,
      do: List.foldl(children(node), [], fn child, acc -> acc ++ search(child, prefix) end)

  def search(node, [])
      when trie_node(node, :word) == nil,
      do: List.foldl(children(node), [], fn child, acc -> acc ++ search(child) end)

  def search(node, [])
      when trie_node(node, :word) != nil,
      do:
        List.foldl(children(node), [trie_node(node, :word)], fn child, acc ->
          acc ++ search(child)
        end)

  def search(node, [prefix_x])
      when trie_node(node, :x) != prefix_x,
      do: []

  def search(node, [prefix_head | _])
      when trie_node(node, :x) != prefix_head,
      do: []

  def search(node, _)
      when trie_node(node, :children) == [] and trie_node(node, :word) == nil,
      do: []

  def search(node, [prefix_x])
      when trie_node(node, :x) == prefix_x and trie_node(node, :word) != nil,
      do:
        List.foldl(children(node), [trie_node(node, :word)], fn child, acc ->
          acc ++ search(child)
        end)

  def search(node, [prefix_x])
      when trie_node(node, :x) == prefix_x and trie_node(node, :word) == nil,
      do:
        List.foldl(children(node), [], fn child, acc ->
          acc ++ search(child)
        end)

  def search(node, [prefix_head | prefix_tail])
      when trie_node(node, :x) == prefix_head,
      do:
        List.foldl(children(node), [], fn child, acc ->
          acc ++ search(child, prefix_tail)
        end)

  def remove(node, [wordable_head]) do
    case find_child(node, x: wordable_head) do
      nil -> node
      child -> remove_word(node, child)
    end
  end

  def remove(node, [wordable_head | wordable_tail]),
    do:
      trie_node(
        node,
        children:
          List.map_if(
            children(node),
            &node_x_filter(&1, wordable_head),
            &remove(&1, wordable_tail)
          )
      )
      |> remove_trash_children

  def equals?(node, other) when trie_node(node, :x) != trie_node(other, :x), do: false
  def equals?(node, other) when trie_node(node, :word) != trie_node(other, :word), do: false
  def equals?(node, other), do: equals_children?(children(node), children(other))

  defp equals_children?([], []), do: true
  defp equals_children?(_, []), do: false
  defp equals_children?([], _), do: false

  defp equals_children?([head | tail], [other_head | other_tail]) do
    if equals?(head, other_head) do
      equals_children?(tail, other_tail)
    else
      false
    end
  end

  defp find_child(node, x: x), do: List.find(children(node), &node_x_filter(&1, x))

  defp remove_word(parent, child),
    do:
      trie_node(
        parent,
        children:
          List.map_if(
            children(parent),
            &node_x_filter(&1, trie_node(child, :x)),
            &trie_node(&1, word: nil)
          )
      )
      |> remove_trash_children

  defp word_node(x, word), do: trie_node(x: x, word: word)
  defp children(node), do: trie_node(node, :children)
  defp node_x_filter(node, x), do: trie_node(node, :x) == x

  defp remove_trash_children(node),
    do:
      trie_node(
        node,
        children: List.filter(children(node), &(not trash_node(&1)))
      )

  # although word can be `[nil]`, it can't be `nil`
  defp trash_node(node), do: trie_node(node, :word) == nil and trie_node(node, :children) == []
end
