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
                Node.trie_node(
                  x: 3,
                  word: [2, 3],
                  children: [Node.trie_node(x: 4, word: [2, 3, 4])]
                )
              ]
            )
          ]
        )

      trie =
        Trie.new()
        |> Trie.insert([2, 3, 4])
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
        |> Trie.insert([4, 2])
        |> Trie.insert([1, 2, 3])
        |> Trie.insert([1, 2])
        |> Trie.insert([2, 3])

      assert Trie.entries(trie) == [[1, 2], [1, 2, 3], [2, 3], [4, 2]]
    end

    test "first word is stored" do
      assert Trie.new()
             |> Trie.insert(:hello)
             |> Trie.insert("hello")
             |> Trie.entries() == [:hello]

      assert Trie.new()
             |> Trie.insert("hello")
             |> Trie.insert(:hello)
             |> Trie.entries() == ["hello"]
    end

    test "different types same word" do
      trie =
        Trie.new()
        |> Trie.insert("hełło")
        |> Trie.insert([104, 101, 322, 322, 111])
        |> Trie.insert({104, 101, 322, 322, 111})
        |> Trie.insert(:hełło)

      assert Trie.entries(trie) == ["hełło"]

      trie =
        Trie.new()
        |> Trie.insert("hełło")
        |> Trie.insert([104, 101, 322, 322, 111])

      assert Trie.entries(trie) == ["hełło"]

      trie =
        Trie.new()
        |> Trie.insert(123)
        |> Trie.insert([1, 2, 3])

      assert Trie.entries(trie) == [123]
    end

    test "entries are sorted" do
      trie = Trie.new(["b", "abc", "a", "ab", "d", "cd", "c"])

      assert Trie.entries(trie) == ["a", "ab", "abc", "b", "c", "cd", "d"]
    end
  end

  describe "search" do
    test "different types same word" do
      trie =
        Trie.new()
        |> Trie.insert({104, 101, 322, 322, 111})
        |> Trie.insert([1, 2, 3])
        |> Trie.insert({104, 101, 105})
        |> Trie.insert([104, 101])
        |> Trie.insert("hełło")

      assert Trie.search(trie, [104, 101]) == [
               [104, 101],
               {104, 101, 105},
               {104, 101, 322, 322, 111}
             ]
    end
  end

  describe "add/remove" do
    test "add is same as insert" do
      assert Trie.new() |> Trie.insert("hełło") == Trie.new() |> Trie.add("hełło")
    end

    test "initial trie after add and remove" do
      trie =
        Trie.new()
        |> Trie.add("add")
        |> Trie.remove("add")

      assert Trie.entries(trie) == []
      assert trie == Trie.new()
    end

    test "add all" do
      words = ["1", "2", "3"]

      trie =
        Trie.new()
        |> Trie.add_all(words)

      assert Trie.entries(trie) == words
    end
  end

  test "foldl" do
    trie =
      Trie.new()
      |> Trie.add_all(["3", "2", "1"])

    assert Trie.foldl(trie, [], &[&1 <> ")" | &2]) == ["3)", "2)", "1)"]
  end

  test "foldr" do
    trie =
      Trie.new()
      |> Trie.add_all(["3", "2", "1"])

    assert Trie.foldr(trie, [], &[&1 <> ")" | &2]) == ["1)", "2)", "3)"]
  end

  test "filter" do
    trie =
      Trie.new(["1", "2", "22222", {123}])
      |> Trie.filter(&(not is_bitstring(&1)))

    assert Trie.entries(trie) == [{123}]
  end

  test "map" do
    trie =
      Trie.new(["1", "2", "3"])
      |> Trie.map(&(&1 <> "."))

    assert Trie.entries(trie) == ["1.", "2.", "3."]
  end

  test "merge" do
    trie =
      Trie.new(["a", "lot", "of", "words"])
      |> Trie.merge(Trie.new(["3", "more", "words"]))

    assert Trie.entries(trie) == ["3", "a", "lot", "more", "of", "words"]
  end

  describe "equals" do
    test "same wordable" do
      trie = Trie.new(["hełło"])
      other = Trie.new([:hełło])

      assert Trie.equals?(trie, other) == false
    end

    test "same words" do
      trie = Trie.new([" ", "Equivalence", "..."])
      other = Trie.new(["Equivalence", " ", "..."])

      assert Trie.equals?(trie, other) == true
    end
  end
end
