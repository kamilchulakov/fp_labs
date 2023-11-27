defmodule Trie do
  @moduledoc """
  Provides a Trie.

  ### Links
    - https://en.wikipedia.org/wiki/Trie
  """

  alias Trie.Node

  defstruct [:root]

  @type word :: String.t()
  @type t :: %__MODULE__{root: Node.trie_node()}

  @spec new(root :: Node.trie_node()) :: t
  def new(root), do: %__MODULE__{root: root}

  @spec insert(trie :: t, word :: word) :: t
  def insert(trie, word) do
    # {node, leftovers} = find_node
    # new = node_insert(node, leftovers)
    # set_new
    trie
  end

  @spec delete(trie :: t, word :: String.t()) :: t
  def delete(trie, word), do: trie

  @spec search(trie :: t, prefix :: word) :: [Node.trie_node()]
  def search(trie, word), do: [trie.root]
end
