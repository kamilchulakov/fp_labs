defmodule TrieTest do
  use ExUnit.Case

  require Trie
  require Trie.Node

  alias Trie.Node



  test "new" do
    Trie.new(Node.trie_node(x: "string"))
  end
end
