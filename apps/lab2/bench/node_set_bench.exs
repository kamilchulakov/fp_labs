require Benchee

alias Trie.NodeSet

inputs = %{
  "small set" => Enum.to_list(1..100),
  "medium set" => Enum.to_list(1..10_000),
  "large set" => Enum.to_list(1..1_000_000)
}

Benchee.run(
  %{
    "find" => fn set -> Enum.each(set, fn x -> NodeSet.find(set, fn y -> y == x end) end) end,
    "filter" => fn set -> Enum.each(set, fn x -> NodeSet.filter(set, fn y -> y == x end) end) end
  },
  inputs: inputs
)
