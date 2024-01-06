defmodule Trie.Node do
  @moduledoc """
  Provides a node record with children set and is_end flag
  """

  require Record

  Record.defrecord(:trie_node, x: nil, children: [], is_end: false)

  @type trie_node :: record(:trie_node, x: any(), children: [trie_node], is_end: boolean)
  @type trie_node(x) :: record(:trie_node, x: x, children: [trie_node], is_end: boolean)
end
