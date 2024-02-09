defmodule Lab3.Interpolation.LinearTest do
  use ExUnit.Case

  alias Lab3.Interpolation.Linear

  test "[{1, 1}, {3, 4}]" do
    {xs, ys} = Linear.interpolate([{1, 1}, {3, 4}], 1)

    assert xs == [1, 2, 3]
    assert ys == [1, 2.5, 4]
  end
end
