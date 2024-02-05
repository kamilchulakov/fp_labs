defprotocol Trie.Wordable do
  def to_wordable(data)
end

defimpl Trie.Wordable, for: List do
  def to_wordable(list) when length(list) != 0, do: list
end

defimpl Trie.Wordable, for: Tuple do
  def to_wordable(tuple) when tuple_size(tuple) != 0, do: Tuple.to_list(tuple)
end

defimpl Trie.Wordable, for: BitString do
  def to_wordable(str), do: to_charlist(str)
end

defimpl Trie.Wordable, for: Atom do
  def to_wordable(atom), do: Atom.to_charlist(atom)
end

defimpl Trie.Wordable, for: Integer do
  def to_wordable(integer), do: Integer.digits(integer)
end
