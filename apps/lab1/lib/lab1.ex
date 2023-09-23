defmodule Lab1 do
  @moduledoc """
  Documentation for `Lab1`.
  """

  defp is_palindrome(num) do
    num
    |> Integer.to_string()
    |> String.reverse()
    |> String.to_integer() == num
  end

  defp is_palindrome_product(x, y), do: x * y |> is_palindrome
  
  def largest_palindrome_product_of_3digit_numbers do
    for x <- 999..100, y <- 999..100,
      is_palindrome_product(x, y) do x * y
    end
      |> Enum.max()
  end
end
