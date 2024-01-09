defmodule TrieTest do
  use ExUnit.Case

  require Trie
  require Trie.Node

  alias Trie.Node

  test "new" do
    assert Trie.new() == %Trie{root: Node.trie_node(x: nil)}
  end

  describe "insert" do
    test "single" do
      trie = Trie.new()
      new_trie = Trie.insert(trie, [1, 2, 3])
      assert new_trie != trie

      expected_root = Node.trie_node(children: [Node.trie_node(x: 1, children: [Node.trie_node(x: 2, children: [Node.trie_node(x: 3, word_end: true)])])])
      assert new_trie.root == expected_root
    end

    test "multiple" do
      expected_root = Node.trie_node(children: [
        Node.trie_node(x: 1, children: [Node.trie_node(x: 2, word_end: true, children: [Node.trie_node(x: 3, word_end: true)])]),
        Node.trie_node(x: 2, children: [Node.trie_node(x: 3, word_end: true)]),
      ])

      trie = Trie.new()
      |> Trie.insert([1, 2, 3])
      |> Trie.insert([1, 2])
      |> Trie.insert([2, 3])

      assert trie.root == expected_root
    end
  end
end
