defmodule Trie.WordableTest do
  use ExUnit.Case

  import Trie.Wordable

  test "empty list is not wordable" do
    assert_raise FunctionClauseError, fn ->
      to_wordable([])
    end
  end

  test "non-empty list is wordable " do
    assert to_wordable([1, 2]) == [1, 2]
  end

  test "string is wordable" do
    assert to_wordable("hełło") == [104, 101, 322, 322, 111]
  end
end
