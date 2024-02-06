defmodule Trie.ListTest do
  use ExUnit.Case

  alias Trie.List

  test "module exists" do
    assert is_list(List.module_info())
  end

  test "filter" do
    assert List.filter([1, 2, 3], fn x -> x != 2 end) == [1, 3]
  end

  test "find returns first matched element" do
    assert List.find([1, 2], fn _ -> true end) == 1
  end
end
