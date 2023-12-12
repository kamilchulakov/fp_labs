defmodule Trie.NodeSetTest do
  use ExUnit.Case

  alias Trie.NodeSet

  test "module exists" do
    assert is_list(NodeSet.module_info())
  end

  test "filter" do
    assert NodeSet.filter([1, 2, 3], fn x -> x != 2 end) == [1, 3]
  end

  test "find returns first matched element" do
    assert NodeSet.find([1, 2], fn _ -> true end) == 1
  end


end
