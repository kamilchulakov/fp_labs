defmodule Trie.Node do
  @moduledoc """
  Provides a node record with children set and is_end flag
  """

  require Record

  Record.defrecord(:trie_node, x: nil, children: [], word_end: false)

  @type trie_node :: record(:trie_node, x: any(), children: [trie_node], word_end: boolean)
  @type trie_node(x) :: record(:trie_node, x: x, children: [trie_node(x)], word_end: boolean)

  def insert(node, word) when trie_node(node, :x) == nil and is_list(word), do: trie_node(node, children: insert_child(children(node), word))
  def insert(node, [x]) when trie_node(node, :x) == x, do: trie_node(node, word_end: true)
  def insert(node, [head | tail]) when trie_node(node, :x) == head, do: trie_node(node, children: insert_child(children(node), tail))

  defp insert_child(children \\ [], word)

  defp insert_child([], [x]), do: [word_node(x)]
  # TODO: refactor
  defp insert_child([head | tail], [x]) when trie_node(head, :x) == x, do: [trie_node(head, word_end: true) | tail]
  defp insert_child([head | tail], [x]) when trie_node(head, :x) != x, do: [head | insert_child(tail, x)]

  defp insert_child([], [head | tail]), do: [trie_node(x: head, children: insert_child(tail))]
  defp insert_child([head_child | tail_child], [head_x | tail_x]) when trie_node(head_child, :x) == head_x, do: [insert(head_child, [head_x | tail_x]) | tail_child]
  defp insert_child([head_child | tail_child], [head_x | tail_x]) when trie_node(head_child, :x) != head_x, do: [head_child | insert_child(tail_child, [head_x | tail_x])]

  defp word_node(x), do: trie_node(x: x, word_end: true)
  defp children(node), do: trie_node(node, :children)
end
