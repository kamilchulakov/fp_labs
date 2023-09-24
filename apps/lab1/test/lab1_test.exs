defmodule Lab1Test do
  use ExUnit.Case
  doctest Lab1

  test "largest palindrome product of 3-digit numbers" do
    assert Lab1.largest_palindrome_product_of_3digit_numbers() == 906_609
  end
end
