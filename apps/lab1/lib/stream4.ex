defmodule Stream4 do
  @moduledoc false

  @min_num 100
  @max_num 999
  @min_max_range @min_num..@max_num
  @nums_count @min_max_range |> Enum.count()

  defmacro is_even(integer) do
    quote do: rem(unquote(integer), 2) == 0
  end

  defp drop_last(enumerable), do: Enum.take(enumerable, length(enumerable) - 1)

  defp is_mirrored({[], []}), do: true
  defp is_mirrored({[x], [x]}), do: true

  defp is_mirrored({[head1 | tail1], [head2 | tail2]}) do
    if head1 != Enum.at(tail2, -1) || head2 != Enum.at(tail1, -1) do
      false
    else
      is_mirrored({drop_last(tail1), drop_last(tail2)})
    end
  end

  defp split_by_count(enumerable), do: split_by_count(enumerable, Enum.count(enumerable))

  defp split_by_count(enumerable, count) when is_even(count),
    do: Enum.split(enumerable, div(count, 2))

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

  def foldr([head | []], acc, fun), do: fun.(head, acc)
  def foldr([head | tail], acc, fun), do: fun.(head, foldr(tail, acc, fun))
  def foldr(stream, acc, fun), do: foldr(Enum.to_list(stream), acc, fun)

  def foldl([], acc, _fun), do: acc
  def foldl([head | tail], acc, fun), do: foldl(tail, fun.(head, acc), fun)
  def foldl(stream, acc, fun), do: foldl(Enum.to_list(stream), acc, fun)

  defp max_product(stream) do
    stream
    |> foldl(nil, fn product, acc ->
      cond do
        acc == nil -> product
        product > acc -> product
        true -> acc
      end
    end)
  end

  @spec largest_palindrome_product_of_3digit_numbers_cycle :: integer
  def largest_palindrome_product_of_3digit_numbers_cycle do
    range_cycle = Stream.cycle(@min_max_range)
    range_to_x = &Stream.take(range_cycle, &1 - @min_num)
    map_to_product = &Stream.map(&1, fn y -> &2 * y end)

    range_cycle
    |> Stream.take(@nums_count)
    |> Stream.flat_map(fn x ->
      range_to_x.(x)
      |> map_to_product.(x)
    end)
    |> Stream.filter(&is_palindrome(&1))
    |> max_product()
  end

  @spec largest_palindrome_product_of_3digit_numbers_iter :: integer
  def largest_palindrome_product_of_3digit_numbers_iter do
    map_next = &Stream.map(&1..@max_num, fn y -> &1 * y end)

    next_fun = fn {num, _} ->
      next_num = num + 1
      {next_num, map_next.(next_num)}
    end

    iterate_stream = Stream.iterate({@min_num - 1, []}, next_fun)
    map_to_products = fn {_, products} -> products end

    iterate_stream
    |> Stream.take(@nums_count)
    |> Stream.flat_map(map_to_products)
    |> Stream.filter(&is_palindrome(&1))
    |> max_product()
  end
end
