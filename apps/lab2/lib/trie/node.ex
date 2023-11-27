defmodule Trie.Node do
  @moduledoc """
  Provides a node record with children set and is_end flag
  """

  require Record

  Record.defrecord(:trie_node, children: [], is_end: false)

  @type trie_node :: record(:trie_node, children: [trie_node], is_end: boolean)
end
