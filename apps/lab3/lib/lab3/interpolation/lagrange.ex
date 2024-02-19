defmodule Lab3.Interpolation.Lagrange do
  @moduledoc """
  Implements Lagrange interpolation.

  - https://en.wikipedia.org/wiki/Polynomial_interpolation#Lagrange_Interpolation
  """

  alias Lab3.Util.FloatStream

  def interpolate(points, step) do
    y = polynomial_fun(points)
    {x0, _} = List.first(points)
    {xn, _} = List.last(points)

    FloatStream.new(x0, xn, step)
    |> Stream.map(fn x -> {x, y.(x)} end)
    |> Enum.to_list()
  end

  defp polynomial_fun(points) do
    xs =
      points
      |> Enum.map(fn {x, _} -> x end)

    polynomials =
      points
      |> Enum.with_index()
      |> Enum.map(fn {point, i} -> polynomial(xs, point, i) end)

    fn x ->
      polynomials
      |> Enum.map(& &1.(x))
      |> Enum.reduce(&(&1 + &2))
    end
  end

  defp polynomial(xs, {point_x, point_y}, i) do
    fn x ->
      xs
      |> List.delete_at(i)
      |> Enum.map(&((x - &1) / (point_x - &1)))
      |> Enum.reduce(&(&1 * &2))
      |> mult(point_y)
    end
  end

  defp mult(x, y), do: x * y
end
