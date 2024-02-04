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

      expected_root =
        Node.trie_node(
          children: [
            Node.trie_node(
              x: 1,
              children: [Node.trie_node(x: 2, children: [Node.trie_node(x: 3, word: [1, 2, 3])])]
            )
          ]
        )

      assert new_trie.root == expected_root
    end

    test "any wordable" do
      trie =
        Trie.new()
        |> Trie.insert([1, 2])
        |> Trie.insert("34")

      expected_trie = %Trie{
        root:
          Node.trie_node(
            children: [
              Node.trie_node(
                x: 1,
                children: [
                  Node.trie_node(x: 2, word: [1, 2])
                ]
              ),
              Node.trie_node(
                x: 51,
                children: [
                  Node.trie_node(x: 52, word: "34")
                ]
              )
            ]
          )
      }

      assert trie == expected_trie
    end

    test "multiple" do
      expected_root =
        Node.trie_node(
          children: [
            Node.trie_node(
              x: 1,
              children: [
                Node.trie_node(
                  x: 2,
                  word: [1, 2],
                  children: [
                    Node.trie_node(x: 3, word: [1, 2, 3])
                  ]
                )
              ]
            ),
            Node.trie_node(
              x: 2,
              children: [
                Node.trie_node(x: 3, word: [2, 3])
              ]
            )
          ]
        )

      trie =
        Trie.new()
        |> Trie.insert([1, 2, 3])
        |> Trie.insert([1, 2])
        |> Trie.insert([2, 3])

      assert trie.root == expected_root
    end
  end

  describe "entries" do
    test "simple" do
      trie =
        Trie.new()
        |> Trie.insert([1, 2, 3])
        |> Trie.insert([1, 2])
        |> Trie.insert([2, 3])

      assert Trie.entries(trie) == [[1, 2], [1, 2, 3], [2, 3]]
    end
  end
end
