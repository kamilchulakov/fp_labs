defmodule Trie.NodeChildrenTest do
  use ExUnit.Case

  alias Trie.NodeChildren

  test "module exists" do
    assert is_list(NodeChildren.module_info())
  end

  test "filter" do
    assert NodeChildren.filter([1, 2, 3], fn x -> x != 2 end) == [1, 3]
  end

  test "find returns first matched element" do
    assert NodeChildren.find([1, 2], fn _ -> true end) == 1
  end
end
