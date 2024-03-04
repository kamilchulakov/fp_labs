defmodule Lab4.Commander.Parser do
  require Logger

  def parse(raw_command) do
    [command | args] = String.split(raw_command)

    try do
      parse(command, args)
      |> to_command(raw_command)
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
    {:create_index, name, parse_filter(filter), :global}
  end

  defp parse("CREATE", ["LOCAL" | ["INDEX" | [name | filter]]]) do
    {:create_index, name, parse_filter(filter)}
  end

  defp parse("DELETE", ["INDEX", name]) do
    {:delete_index, name, :global}
  end

  defp parse("DELETE", ["LOCAL" | ["INDEX", name]]) do
    {:delete_index, name}
  end

  defp parse("FETCH", ["INDEX", name]) do
    {:fetch_index, name, :global}
  end

  defp parse("FETCH", ["LOCAL" | ["INDEX", name]]) do
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

  defp to_command(parsed_command, raw_command) do
    global_arg_index =
      parsed_command
      |> Tuple.to_list()
      |> Enum.find_index(&(&1 == :global))

    case global_arg_index do
      nil ->
        parsed_command

      _ ->
        [
          local: Tuple.delete_at(parsed_command, global_arg_index),
          global: to_local(raw_command),
          type: global_type(raw_command)
        ]
    end
  end

  defp to_local(raw_command) do
    raw_command
    |> String.replace("CREATE INDEX", "CREATE LOCAL INDEX")
    |> String.replace("FETCH INDEX", "FETCH LOCAL INDEX")
    |> String.replace("DELETE INDEX", "DELETE LOCAL INDEX")
  end

  defp global_type(raw_command) do
    if String.starts_with?(raw_command, "FETCH") do
      :concat
    else
      :ok
    end
  end
end
