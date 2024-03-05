defmodule Lab4.Commander.Parser do
  require Logger
  import NimbleParsec

  some_space =
    utf8_string([?\n, ?\r, ?\s, ?\t], min: 0)

  good_string =
    utf8_string([not: ?\r, not: ?\n, not: ?,, not: ?\s], min: 1)

  key = good_string

  index_name =
    good_string
    |> unwrap_and_tag(:index_name)

  value =
    choice([integer(min: 1), good_string])

  get =
    ignore(string("GET"))
    |> ignore(some_space)
    |> concat(key)
    |> optional(ignore(some_space))
    |> unwrap_and_tag(:get)

  set =
    ignore(string("SET"))
    |> ignore(some_space)
    |> concat(key)
    |> ignore(some_space)
    |> concat(value)
    |> optional(ignore(some_space))
    |> tag(:set)

  purge =
    ignore(string("PURGE"))
    |> optional(ignore(some_space))
    |> tag(:purge)

  less_filter =
    ignore(string("LESS"))
    |> ignore(some_space)
    |> concat(value)
    |> unwrap_and_tag(:less)

  more_filter =
    ignore(string("MORE"))
    |> ignore(some_space)
    |> concat(value)
    |> unwrap_and_tag(:more)

  starts_with_filter =
    ignore(string("STARTS"))
    |> ignore(some_space)
    |> ignore(string("WITH"))
    |> ignore(some_space)
    |> concat(value)
    |> unwrap_and_tag(:starts_with)

  ends_with_filter =
    ignore(string("ENDS"))
    |> ignore(some_space)
    |> ignore(string("WITH"))
    |> ignore(some_space)
    |> concat(value)
    |> unwrap_and_tag(:ends_with)

  filter =
    choice([
      less_filter,
      more_filter,
      starts_with_filter,
      ends_with_filter
    ])

  create_index =
    ignore(string("CREATE"))
    |> ignore(some_space)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> ignore(some_space)
    |> concat(filter)
    |> optional(ignore(some_space))
    |> tag(:create_index)

  create_local_index =
    ignore(string("CREATE"))
    |> ignore(some_space)
    |> ignore(string("LOCAL"))
    |> ignore(some_space)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> ignore(some_space)
    |> concat(filter)
    |> optional(ignore(some_space))
    |> tag(:create_local_index)

  delete_index =
    ignore(string("DELETE"))
    |> ignore(some_space)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> optional(ignore(some_space))
    |> tag(:delete_index)

  delete_local_index =
    ignore(string("DELETE"))
    |> ignore(some_space)
    |> ignore(string("LOCAL"))
    |> ignore(some_space)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> optional(ignore(some_space))
    |> tag(:delete_local_index)

  fetch_index =
    ignore(string("FETCH"))
    |> ignore(some_space)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> optional(ignore(some_space))
    |> tag(:fetch_index)

  fetch_local_index =
    ignore(string("FETCH"))
    |> ignore(some_space)
    |> ignore(string("LOCAL"))
    |> ignore(some_space)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> optional(ignore(some_space))
    |> tag(:fetch_local_index)

  defparsec(
    :parse,
    choice([
      get,
      set,
      purge,
      create_index,
      create_local_index,
      delete_index,
      delete_local_index,
      fetch_index,
      fetch_local_index
    ])
  )

  def parse_and_put_opts(raw_command) do
    case parse(raw_command) do
      {:error, _reason, _rest, _context, _line, _column} ->
        {:error, :bad_args}

      {:ok, [parsed_command], _rest, _context, _line, _column} ->
        parsed_command
        |> put_opts(raw_command)
    end
  end

  defp put_opts({command, args} = parsed_command, raw_command) do
    if local?(command) do
      {drop_local(command), args}
    else
      [
        local: parsed_command,
        global: to_local_raw(raw_command),
        type: global_type(command)
      ]
    end
  end

  defp local?(command) do
    cond do
      command in [:get, :set, :purge] -> true
      String.contains?(to_string(command), "local") -> true
      true -> false
    end
  end

  defp drop_local(command) do
    cond do
      command in [:get, :set, :purge] -> command
      true ->
        to_string(command)
        |> String.replace("_local", "")
        |> String.to_atom()
    end
  end

  defp to_local_raw(raw_command) do
    raw_command
    |> String.replace("CREATE INDEX", "CREATE LOCAL INDEX")
    |> String.replace("FETCH INDEX", "FETCH LOCAL INDEX")
    |> String.replace("DELETE INDEX", "DELETE LOCAL INDEX")
  end

  defp global_type(command) do
    if command == :fetch_index do
      :concat
    else
      :ok
    end
  end
end
