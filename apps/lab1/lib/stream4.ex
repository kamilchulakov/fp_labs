defmodule Stream4 do
  @moduledoc false
  import Comprehensions4, only: [is_palindrome: 1]

  @min_num 100
  @max_num 999
  @min_max_range @min_num..@max_num

  @spec largest_palindrome_product_of_3digit_numbers :: integer
  def largest_palindrome_product_of_3digit_numbers do
    range_cycle = Stream.cycle(@min_max_range)
    range_to_x = fn x -> Stream.take(range_cycle, x - @min_num) end

    map_to_product = fn stream, x -> Stream.map(stream, fn y -> x * y end) end

    max_product = fn stream ->
      Enum.reduce(stream, nil, fn product, acc ->
        cond do
          acc == nil -> product
          product > acc -> product
          true -> acc
        end
      end)
    end

    range_cycle
    |> Stream.take(@max_num - @min_num + 1)
    |> Stream.flat_map(fn x ->
      range_to_x.(x)
      |> map_to_product.(x)
    end)
    |> Stream.filter(fn product -> is_palindrome(product) end)
    |> max_product.()
  end
end
