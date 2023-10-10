defmodule Comprehensions4Test do
  use ExUnit.Case
  doctest Comprehensions4

  test "largest palindrome product of 3-digit numbers" do
    assert Comprehensions4.largest_palindrome_product_of_3digit_numbers() == 906_609
  end
end
