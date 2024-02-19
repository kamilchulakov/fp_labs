defmodule Lab3.ConfigTest do
  use ExUnit.Case

  alias Lab3.Config

  test "no args" do
    assert_raise RuntimeError, "--step <value> is missing", fn ->
      Config.new([])
    end
  end

  test "no step arg" do
    assert_raise RuntimeError, "--step <value> is missing", fn ->
      Config.new(["--window", "10"])
    end
  end

  test "default window" do
    assert Config.new(["--step", "0.2"]) == %Config{window: 5, step: 0.2}
  end

  test "window and step args" do
    assert Config.new(["--window", "10", "--step", "0.2"]) == %Config{window: 10, step: 0.2}
  end
end
