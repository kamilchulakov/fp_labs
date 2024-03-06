defimpl Jason.Encoder, for: Tuple do
  def encode({key, value}, opts) do
    Jason.Encode.map(%{key => value}, opts)
  end
end
