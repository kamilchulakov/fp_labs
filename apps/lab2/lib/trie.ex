defmodule Trie do
  @moduledoc """
  Implements a Trie.

  ### TODO:
  - [x] insert
  - [x] search
  - [x] entries

  - [x] wordable protocol
  - [ ] keyword list
  - [x] store word in node

  ### Links
    - https://en.wikipedia.org/wiki/Trie
  """

  require Record
  require Trie.Node

  alias Trie.Node
  alias Trie.Wordable

  defstruct [:root]

  @typedoc """
    Type that represents #{Trie.Node} value.
    Only root nodes have nil.
  """
  @type x :: char() | integer() | binary() | nil

  @typedoc """
    Type that represents stored word.
  """
  @type word :: list(x()) | tuple() | bitstring() | atom()

  @type t :: %__MODULE__{root: Node.trie_node(x())}

  @spec new() :: t()
  def new, do: %__MODULE__{root: Node.trie_node(x: nil)}

  @spec insert(trie :: t(), word :: word()) :: t()
  def insert(%__MODULE__{root: root}, word) do
    %__MODULE__{
      root: Node.insert(root, Wordable.to_wordable(word), word)
    }
  end

  @spec entries(trie :: t()) :: [word()]
  def entries(%__MODULE__{root: root}), do: Node.entries(root)

  @spec search(trie :: t(), prefix: word()) :: [word()]
  def search(%__MODULE__{root: root}, prefix), do: Node.search(root, Wordable.to_wordable(prefix))
end
