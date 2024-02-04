defprotocol Trie.Wordable do
  def to_wordable(data)
end

defimpl Trie.Wordable, for: List do
  def to_wordable(list) when length(list) != 0, do: list
end

defimpl Trie.Wordable, for: BitString do
  def to_wordable(str), do: to_charlist(str)
end
