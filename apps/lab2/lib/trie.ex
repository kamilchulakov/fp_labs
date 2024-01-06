defmodule Trie do
  @moduledoc """
  Implements a Trie.

  ### Links
    - https://en.wikipedia.org/wiki/Trie
  """

  alias Trie.Node

  defstruct [:root]

  @typedoc """
    #{Trie.Node} value type.
  """
  @type x :: char() | integer() | binary()

  @type t(x) :: %__MODULE__{root: Node.trie_node(x)}

  @spec new(root :: Node.trie_node(x)) :: t(x)
  def new(root), do: %__MODULE__{root: root}

  # TODO:
  # insert
  # search
  # entries
end
