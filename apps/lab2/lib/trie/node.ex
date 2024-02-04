defmodule Trie.Node do
  @moduledoc """
  Provides a node record with children set and is_end flag
  """
  alias Trie.NodeChildren
  require Record

  Record.defrecord(:trie_node, x: nil, children: [], word: nil)

  @type trie_node :: record(:trie_node, x: any(), children: [trie_node], word: any())
  @type trie_node(x) :: record(:trie_node, x: x, children: [trie_node(x)], word: any())

  def insert(node, wordable, word) when trie_node(node, :x) == nil and is_list(wordable),
    do: trie_node(node, children: insert_child(children(node), wordable, word))

  def insert(node, [x], word) when trie_node(node, :x) == x, do: trie_node(node, word: word)

  def insert(node, [head | tail], word) when trie_node(node, :x) == head,
    do: trie_node(node, children: insert_child(children(node), tail, word))

  defp insert_child(children \\ [], wordable, word)

  defp insert_child([], [x], word), do: [word_node(x, word)]

  defp insert_child([head | tail], [x], word) when trie_node(head, :x) == x,
    do: [trie_node(head, word: word) | tail]

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
      when trie_node(node, :children) == [] and trie_node(node, :word) != nil,
      do: [node_word(node, prefix)]

  def search(node, _)
      when trie_node(node, :children) == [] and trie_node(node, :word) == nil,
      do: []

  def search(node, prefix)
      when trie_node(node, :x) != nil and trie_node(node, :word) != nil,
      do:
        NodeChildren.foldl(children(node), [], fn child, acc ->
          acc ++ [node_word(node, prefix)] ++ search(child, node_word(node, prefix))
        end)

  def search(node, prefix)
      when trie_node(node, :x) != nil and trie_node(node, :word) == nil,
      do:
        NodeChildren.foldl(children(node), [], fn child, acc ->
          acc ++ search(child, node_word(node, prefix))
        end)

  defp node_word(node, _prefix), do: trie_node(node, :word)
  defp word_node(x, word), do: trie_node(x: x, word: word)
  defp children(node), do: trie_node(node, :children)
end
