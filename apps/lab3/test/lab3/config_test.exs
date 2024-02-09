defmodule Lab3.ConfigTest do
  use ExUnit.Case

  alias Lab3.Config

  test "default" do
    assert Config.new([]) == %Config{window: 5}
  end

  test "window arg" do
    assert Config.new(["--window", "10"]) == %Config{window: 10}
  end
end
