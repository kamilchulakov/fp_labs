defmodule Solution27 do
  @moduledoc false
  @limit_a -1000..999
  @limit_b -1000..1000

  defp calc_by_formula(n, a, b) do
    n * n + a * n + b
  end

  defp max_continuous_prime(n, a, b) do
    if ElixirMath.PrimeGenerator.is_prime(calc_by_formula(n, a, b)) do
      max_continuous_prime(n + 1, a, b)
    else
      [n, a, b]
    end
  end

  defp comparator([n, _, _]), do: n

  defp find_best do
    for a <- @limit_a, b <- @limit_b do
      max_continuous_prime(0, a, b)
    end
    |> Enum.max_by(&comparator(&1), fn -> nil end)
  end

  def solve do
    find_best()
    |> Enum.drop(1)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end
end
