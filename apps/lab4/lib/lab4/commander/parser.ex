defmodule Lab4.Commander.Parser do
  require Logger

  def parse(raw_command) do
    [command | args] = String.split(raw_command)

    try do
      parse(command, args)
    rescue
      FunctionClauseError ->
        :bad_args
    end
  end

  defp parse("GET", [key]) do
    {:get, key}
  end

  defp parse("SET", [key, value]) do
    {:set, key, value}
  end

  defp parse("PURGE", []) do
    :purge
  end

  defp parse("CREATE", ["INDEX" | [name | filter]]) do
    {:create_index, name, parse_filter(filter)}
  end

  defp parse("DELETE", ["INDEX", name]) do
    {:delete_index, name}
  end

  defp parse("FETCH", ["INDEX", name]) do
    {:fetch_index, name}
  end

  defp parse_filter(["LESS", data]) do
    {:less, data}
  end

  defp parse_filter(["MORE", data]) do
    {:more, data}
  end

  defp parse_filter(["STARTS" | ["WITH" | data]]) do
    {:starts_with, data}
  end

  defp parse_filter(["ENDS", ["WITH" | data]]) do
    {:ends_with, data}
  end
end
