defmodule Solution27 do
  @moduledoc false

  @limit_a -1000..999
  @limit_b -1000..1000

  defp calc_by_formula(n, a, b), do: n * n + a * n + b

  defp max_continuous_prime(n \\ 0, a, b) do
    if ElixirMath.PrimeGenerator.is_prime(calc_by_formula(n, a, b)) do
      max_continuous_prime(n + 1, a, b)
    else
      [n, a, b]
    end
  end

  defp find_best do
    for a <- @limit_a, b <- @limit_b do
      max_continuous_prime(a, b)
    end
    |> Enum.max_by(& &1)
  end

  def solve do
    find_best()
    |> Enum.drop(1)
    |> Enum.reduce(1, &(&1 * &2))
  end
end
