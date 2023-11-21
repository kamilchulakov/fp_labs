defmodule Stream4 do
  @moduledoc false
  import Comprehensions4, only: [is_palindrome: 1]

  @min_num 100
  @max_num 999

  @spec largest_palindrome_product_of_3digit_numbers :: integer
  def largest_palindrome_product_of_3digit_numbers do
    range_cycle = Stream.cycle(@min_num..@max_num)

    range_cycle
    |> Stream.take(@max_num - @min_num + 1)
    |> Stream.flat_map(fn x ->
        Stream.take(range_cycle, x - @min_num)
        |> Stream.map(fn y -> x * y end)
      end)
    |> Stream.filter(fn product -> is_palindrome(product) end)
    |> Enum.max()
  end
end
