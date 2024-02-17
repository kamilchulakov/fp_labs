defmodule Comprehensions4 do
  @moduledoc """
  Documentation for `Comprehensions4`.
  """

  defp palindrome?(num) do
    num
    |> Integer.to_string()
    |> String.reverse()
    |> String.to_integer() == num
  end

  defp palindrome_product?(x, y), do: (x * y) |> palindrome?

  @spec largest_palindrome_product_of_3digit_numbers :: integer
  def largest_palindrome_product_of_3digit_numbers do
    for x <- 999..100, y <- x..100, palindrome_product?(x, y) do
      x * y
    end
    |> Enum.max()
  end
end
