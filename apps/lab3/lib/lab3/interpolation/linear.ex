defmodule Lab3.Interpolation.Linear do
  @moduledoc """
  Implements linear interpolation.

  - https://en.wikipedia.org/wiki/Linear_interpolation
  """
  def interpolate([{x0, y0}, {x1, y1}], step) do
    y = fn x -> (y0 * (x1 - x) + y1 * (x - x0)) / (x1 - x0) end

    # Should implement float range?
    # https://stackoverflow.com/questions/34383303/range-of-floating-point-numbers
    xs = [1, 2, 3]
    ys = Enum.map(xs, fn x -> y.(x) end)

    {xs, ys}
  end
end
