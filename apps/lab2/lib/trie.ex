defmodule Trie do
  @moduledoc """
  Implements a Trie.

  ### TODO:
  - [ ] insert
  - [ ] search
  - [ ] entries

  ### Links
    - https://en.wikipedia.org/wiki/Trie
  """

  require Record
  alias Trie.Node

  defstruct [:root]

  @typedoc """
    Type that represents #{Trie.Node} value.
  """
  @type x :: char() | integer() | binary()

  @typedoc """
    Type that represents stored word.
  """
  @type word :: list(x())

  @type t :: %__MODULE__{root: Node.trie_node(x())}

  @spec new(root :: Node.trie_node(x())) :: t()
  def new(root) when Record.is_record(root), do: %__MODULE__{root: root}

  @spec insert(trie :: t(), word :: word()) :: t()
  def insert(trie, _word) do
    trie
  end
end
