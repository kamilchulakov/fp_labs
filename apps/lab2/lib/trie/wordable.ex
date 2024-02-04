defprotocol Trie.Wordable do
  def to_word(data)
end

defimpl Trie.Wordable, for: List do
  def to_word(list) when length(list) != 0, do: list
end


defimpl Trie.Wordable, for: BitString do
  def to_word(str), do: to_charlist(str)
end
