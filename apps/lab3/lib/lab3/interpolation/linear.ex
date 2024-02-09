defmodule Lab3.Interpolation.Linear do
  @moduledoc """
  Implements linear interpolation.

  - https://en.wikipedia.org/wiki/Linear_interpolation
  """

  alias Lab3.Util.FloatStream

  def interpolate([{x0, y0}, {x1, y1}], step) do
    y = fn x -> (y0 * (x1 - x) + y1 * (x - x0)) / (x1 - x0) end

    FloatStream.new(x0, x1, step)
    |> Stream.map(fn x -> {x, y.(x)} end)
    |> Enum.to_list()
  end
end
