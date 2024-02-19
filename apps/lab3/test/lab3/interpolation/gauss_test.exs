defmodule Lab3.Interpolation.GaussTest do
  alias Lab3.Interpolation.Gauss
  use ExUnit.Case

  test "example" do
    assert Gauss.interpolate([{1.0, 1.0}, {2.0, 3.0}, {3.0, 4.0}], 0.5) ==
             [{1.0, 1.0}, {1.5, 2.125}, {2.0, 3.0}, {2.5, 3.625}, {3.0, 4.0}]
  end
end
