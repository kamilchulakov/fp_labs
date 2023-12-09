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
    insert(trie, to_charlist(word))
    {node, leftovers} = find_node(trie.root, word)

    # new = node_insert(node, leftovers)
    # set_new
    trie
  end

  defp insert(trie, chars) do

  end

  @spec delete(trie :: t, word :: String.t()) :: t
  def delete(trie, word), do: trie

  @spec search(trie :: t, prefix :: word) :: [Node.trie_node()]
  def search(trie, word), do: [trie.root]

  defp find_node(root, []), do: {root, []}
  defp find_node(root, [char | word]) do
    node = root.children
           |> Enum.find(fn node -> node.char == char end)
    if node == nil do
      {root, [char, word]}
    else
      find_node(node, word)
    end
  end

  defp insert_node() do

  end

  # TODO:
  # add = insert
  # map
  # filter
  # reduce
  # find = search
  # delete
  # merge
  # size = word count
end
