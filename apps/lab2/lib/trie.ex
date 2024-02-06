defmodule Trie do
  @moduledoc """
  Implements a Trie.

  ### TODO:
  as trie:
  - [x] insert
  - [ ] entries SHOUlD BE SORTED?
  - [ ] search SHOUlD BE SORTED?

  - [x] wordable protocol
  - [-] ~~keyword list~~ (due to protocol implementation, I got no atom keys)
  - [x] store word in node

  as set:
  - [x] add/remove
  - [x] add_all
  - [x] map
  - [x] foldl
  - [x] foldr
  - [x] filter

  - [ ] specs

  - [ ] merge
  - [ ] equals

  ### Links
    - https://en.wikipedia.org/wiki/Trie
  """

  require Record
  require Trie.Node

  alias Trie.List
  alias Trie.Node
  alias Trie.Wordable

  @enforce_keys [:root]
  defstruct [:root]

  @typedoc """
    Type that represents #{Trie.Node} value.
    Only root nodes have nil.
  """
  @type x :: char() | integer() | binary() | nil

  @typedoc """
    Type that represents stored word.
  """
  @type word :: Wordable.t()

  @type t :: %__MODULE__{root: Node.trie_node(x())}

  @spec new() :: t()
  def new, do: %__MODULE__{root: Node.trie_node()}

  @spec new(words :: list(word())) :: t()
  def new(words),
    do:
      new()
      |> add_all(words)

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

  @spec add(trie :: t(), word :: word()) :: t()
  def add(trie, word), do: insert(trie, word)

  @spec add_all(trie :: t(), words :: list(word())) :: t()
  def add_all(trie, words), do: List.foldl(words, trie, &add(&2, &1))

  @spec remove(trie :: t(), word :: word()) :: t()
  def remove(%__MODULE__{root: root}, word),
    do: %__MODULE__{root: Node.remove(root, Wordable.to_wordable(word))}

  def foldl(trie, acc, fun) do
    trie
    |> entries
    |> List.foldl(acc, fun)
  end

  def foldr(trie, acc, fun) do
    trie
    |> entries
    |> List.foldr(acc, fun)
  end

  def filter(trie, predicate) do
    trie
    |> entries
    |> List.filter(predicate)
    |> new
  end

  def map(trie, mapper) do
    trie
    |> entries
    |> List.map(mapper)
    |> new
  end
end
