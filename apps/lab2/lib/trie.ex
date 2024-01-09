defmodule Trie do
  @moduledoc """
  Implements a Trie.

  ### TODO:
  - [x] insert
  - [ ] search
  - [ ] entries

  ### Links
    - https://en.wikipedia.org/wiki/Trie
  """

  require Record
  require Trie.Node

  alias Trie.Node

  defstruct [:root]

  @typedoc """
    Type that represents #{Trie.Node} value.
    Only root nodes have nil.
  """
  @type x :: char() | integer() | binary() | nil

  @typedoc """
    Type that represents stored word.
  """
  @type word :: list(x())

  @type t :: %__MODULE__{root: Node.trie_node(x())}

  @spec new() :: t()
  def new, do: %__MODULE__{root: Node.trie_node(x: nil)}

  @spec insert(trie :: t(), word :: word()) :: t()
  def insert(trie, word) do
    %__MODULE__{
      root: Node.insert(trie.root, word)
    }
  end
end
