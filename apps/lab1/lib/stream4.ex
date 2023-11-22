defmodule Stream4 do
  @moduledoc false

  @min_num 100
  @max_num 999
  @min_max_range @min_num..@max_num
  @nums_count @min_max_range |> Enum.count()

  defmacro is_even(integer) do
    quote do
      rem(unquote(integer), 2) == 0
    end
  end

  defp is_mirrored({[], []}), do: :true
  defp is_mirrored({[head | tail1], tail2}) do
    if head != Enum.at(tail2, -1) do
      :false
    else
      is_mirrored({tail1, Enum.take(tail2, length(tail2) - 1)})
    end
  end


  defp split_by_count(enumerable), do: split_by_count(enumerable, Enum.count(enumerable))
  defp split_by_count(enumerable, count) when is_even(count), do: Enum.split(enumerable, div(count, 2))
  defp split_by_count(enumerable, count) when not is_even(count) do
    head = Enum.take(enumerable, count)
    tail = Enum.take(enumerable, -count)
    {head, tail}
  end

  defp is_palindrome(integer) do
    Integer.digits(integer)
    |> split_by_count
    |> is_mirrored
  end

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
    range_to_x = &(Stream.take(range_cycle, &1 - @min_num))
    map_to_product = &(Stream.map(&1, fn y -> &2 * y end))

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
