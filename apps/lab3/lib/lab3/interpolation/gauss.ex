defmodule Lab3.Interpolation.Gauss do
  @moduledoc """
  Kinda rewritten:
  - https://www.geeksforgeeks.org/gausss-forward-interpolation/
  """

  alias Lab3.Util.FloatStream
  alias Lab3.Util.Matrix

  def interpolate(points, step) do
    xs = Enum.map(points, fn {x, _} -> x end)
    ys = Enum.map(points, fn {_, y} -> y end)

    x0 = List.first(xs)
    xn = List.last(xs)

    FloatStream.new(x0, xn, step)
    |> Stream.map(fn x -> {x, gauss_polynomial(xs, ys, x)} end)
    |> Enum.to_list()
  end

  defp gauss_polynomial(xs, ys, x) do
    n = length(xs)

    # Generating gauss triangle
    triangle =
      Matrix.new(n, n)
      |> Matrix.set_col(0, fn i -> Enum.at(ys, i) end)
      |> Matrix.map(fn matrix, j, i ->
        Matrix.elem(matrix, j + 1, i - 1) - Matrix.elem(matrix, j, i - 1)
      end)

    # Implementing Formula
    p = (x - Enum.at(xs, div(n, 2))) / (Enum.at(xs, 1) - Enum.at(xs, 0))

    Enum.reduce(1..(n - 1), Matrix.elem(triangle, div(n, 2), 0), fn i, acc ->
      acc + p_calc(p, i) * Matrix.elem(triangle, div(n - i, 2), i) / fact(i)
    end)
  end

  defp fact(x) when x > 1, do: x * fact(x - 1)
  defp fact(_), do: 1

  defp p_calc(p, 1), do: p

  defp p_calc(p, n) do
    Enum.reduce(1..(n - 1), p, fn i, acc ->
      acc * (p + -1 ** i * div(i + 1, 2))
    end)
  end
end
