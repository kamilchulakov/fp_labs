defmodule Trie.Node do
  @moduledoc """
  Provides a node record with children set and is_end flag
  """
  alias Trie.NodeChildren
  require Record

  Record.defrecord(:trie_node, x: nil, children: [], word: nil)

  @type trie_node :: record(:trie_node, x: any(), children: [trie_node], word: any())
  @type trie_node(x) :: record(:trie_node, x: x, children: [trie_node(x)], word: any())

  def insert(node, wordable, word) when trie_node(node, :x) == nil,
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

  defp insert_child([head | tail], [x], word) when trie_node(head, :x) != x,
    do: [head | insert_child(tail, x, word)]

  defp insert_child([], [head | tail], word),
    do: [trie_node(x: head, children: insert_child(tail, word))]

  defp insert_child([head_child | tail_child], [head_x | tail_x], word)
       when trie_node(head_child, :x) == head_x,
       do: [insert(head_child, [head_x | tail_x], word) | tail_child]

  defp insert_child([head_child | tail_child], [head_x | tail_x], word)
       when trie_node(head_child, :x) != head_x,
       do: [head_child | insert_child(tail_child, [head_x | tail_x], word)]

  def entries(node)
      when trie_node(node, :x) == nil,
      do: NodeChildren.foldl(children(node), [], fn child, acc -> acc ++ search(child) end)

  def search(node, prefix \\ [])

  def search(node, prefix)
      when trie_node(node, :x) == nil,
      do:
        NodeChildren.foldl(children(node), [], fn child, acc -> acc ++ search(child, prefix) end)

  def search(node, [])
      when trie_node(node, :word) == nil,
      do: NodeChildren.foldl(children(node), [], fn child, acc -> acc ++ search(child) end)

  def search(node, [])
      when trie_node(node, :word) != nil,
      do:
        NodeChildren.foldl(children(node), [trie_node(node, :word)], fn child, acc ->
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
        NodeChildren.foldl(children(node), [trie_node(node, :word)], fn child, acc ->
          acc ++ search(child)
        end)

  def search(node, [prefix_x])
      when trie_node(node, :x) == prefix_x and trie_node(node, :word) == nil,
      do:
        NodeChildren.foldl(children(node), [], fn child, acc ->
          acc ++ search(child)
        end)

  def search(node, [prefix_head | prefix_tail])
      when trie_node(node, :x) == prefix_head and trie_node(node, :word) != nil,
      do:
        NodeChildren.foldl(children(node), [trie_node(node, :word)], fn child, acc ->
          acc ++ search(child, prefix_tail)
        end)

  def search(node, [prefix_head | prefix_tail])
      when trie_node(node, :x) == prefix_head and trie_node(node, :word) == nil,
      do:
        NodeChildren.foldl(children(node), [], fn child, acc ->
          acc ++ search(child, prefix_tail)
        end)

  defp word_node(x, word), do: trie_node(x: x, word: word)
  defp children(node), do: trie_node(node, :children)
end
