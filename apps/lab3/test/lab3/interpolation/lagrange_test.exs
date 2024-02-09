defmodule Lab3.Interpolation.LagrangeTest do
  use ExUnit.Case

  alias Lab3.Interpolation.Lagrange

  test "wiki" do
    data = [{-1.5, -14.1014}, {-0.75, -0.931596}, {0.75, 0.931596}, {1.5, 14.1014}]

    assert Lagrange.interpolate(data, 0.75) == [
             {-1.5, -14.1014},
             {-0.75, -0.931596},
             {0.0, 0.0},
             {0.75, 0.931596},
             {1.5, 14.1014}
           ]
  end
end
