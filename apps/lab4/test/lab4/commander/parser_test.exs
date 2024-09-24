defmodule Lab4.Commander.ParserTest do
  use ExUnit.Case
  alias Lab4.Commander.Parser

  test "get" do
    assert Parser.parse_and_put_opts("GET key-22004") == {:get, ["key-22004"]}
    assert Parser.parse_and_put_opts("GET    key-22004  ") == {:get, ["key-22004"]}
  end

  test "set" do
    assert Parser.parse_and_put_opts("SET key value   ") == {:set, ["key", "value"]}
    assert Parser.parse_and_put_opts("SET key 123") == {:set, ["key", 123]}
    assert Parser.parse_and_put_opts("SET   key [value]") == {:set, ["key", ["value"]]}
    assert Parser.parse_and_put_opts("SET key   [123]") == {:set, ["key", [123]]}
  end
end
