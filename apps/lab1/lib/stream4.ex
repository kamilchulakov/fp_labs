defmodule Stream4 do
  @moduledoc false
  import Comprehensions4, only: [is_palindrome: 1]

  @min_num 100
  @max_num 999
  @min_max_range @min_num..@max_num
  @nums_count @min_max_range |> Enum.count()

  defp reduce([], acc, _fun), do: acc
  defp reduce([head | tail], acc, fun), do: reduce(tail, fun.(head, acc), fun)
  defp reduce(stream, acc, fun), do: reduce(Enum.to_list(stream), acc, fun)

  defp max_product(stream) do
    stream
    |> reduce(nil, fn product, acc ->
      cond do
        acc == nil -> product
        product > acc -> product
        true -> acc
      end
    end)
  end

  @spec largest_palindrome_product_of_3digit_numbers :: integer
  def largest_palindrome_product_of_3digit_numbers do
    range_cycle = Stream.cycle(@min_max_range)
    range_to_x = fn x -> Stream.take(range_cycle, x - @min_num) end

    map_to_product = fn stream, x -> Stream.map(stream, fn y -> x * y end) end

    range_cycle
    |> Stream.take(@nums_count)
    |> Stream.flat_map(fn x ->
      range_to_x.(x)
      |> map_to_product.(x)
    end)
    |> Stream.filter(&is_palindrome(&1))
    |> max_product()
  end
end
