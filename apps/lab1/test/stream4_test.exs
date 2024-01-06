defmodule Stream4Test do
  use ExUnit.Case

  test "largest palindrome product of 3-digit numbers cycle" do
    assert Stream4.largest_palindrome_product_of_3digit_numbers_cycle() == 906_609
  end

  test "largest palindrome product of 3-digit numbers iter" do
    assert Stream4.largest_palindrome_product_of_3digit_numbers_iter() == 906_609
  end
end
