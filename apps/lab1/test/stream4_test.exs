defmodule Solution27Test do
  use ExUnit.Case

  test "largest palindrome product of 3-digit numbers" do
    assert Stream4.largest_palindrome_product_of_3digit_numbers() == 906_609
  end
end
