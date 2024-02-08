defmodule TriePropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  property "Identity element" do
    check all trie <- trie_generator() do
      empty_trie = Trie.new()

      assert Trie.equals?(Trie.merge(empty_trie, trie), trie)
      assert Trie.equals?(Trie.merge(trie, empty_trie), trie)
    end
  end

  property "Associativity" do
    check all trie1 <- trie_generator(), trie2 <- trie_generator(), trie3 <- trie_generator() do
      assert Trie.equals?(
        Trie.merge(Trie.merge(trie1, trie2), trie3),
        Trie.merge(trie1, Trie.merge(trie2, trie3))
      )
    end
  end

  property "Sorted entries" do
    check all trie <- trie_generator() do
      entries = Trie.entries(trie)

      assert entries == Enum.sort(entries)
    end
  end

  defp trie_generator do
    gen all words <- list_of(integer()) do
      Trie.new(words)
    end
  end
end
