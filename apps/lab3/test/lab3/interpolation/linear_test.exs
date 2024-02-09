defmodule Lab3.Interpolation.LinearTest do
  use ExUnit.Case

  alias Lab3.Interpolation.Linear

  test "[{1, 1}, {3, 4}]" do
    assert Linear.interpolate([{1, 1}, {3, 4}], 1) == [{1, 1}, {2, 2.5}, {3, 4}]
  end
end
