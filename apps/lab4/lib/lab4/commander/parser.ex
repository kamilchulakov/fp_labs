defmodule Lab4.Commander.Parser do
  require Logger
  import NimbleParsec

  some_space =
    utf8_string([?\n, ?\r, ?\s, ?\t], min: 1)
    |> label("space")

  good_string =
    utf8_string([not: ?\r, not: ?\n, not: ?,, not: ?\s, not: ?[, not: ?]], min: 1)

  key =
    good_string
    |> label("key")

  index_name =
    good_string
    |> unwrap_and_tag(:index_name)
    |> label("index name")

  value =
    choice([integer(min: 1), good_string])
    |> label("value")

  comma_value =
    optional(ignore(some_space))
    |> ignore(utf8_char([?,]))
    |> optional(ignore(some_space))
    |> concat(value)

  list_of_values =
    ignore(utf8_char([?[]))
    |> concat(value)
    |> times(comma_value, min: 0)
    |> optional(ignore(some_space))
    |> ignore(utf8_char([?]]))
    |> wrap()

  list_or_value =
    choice([
      list_of_values,
      value
    ])

  local_marker =
    ignore(string("LOCAL"))
    |> ignore(some_space)
    |> tag(:local)
    |> label("local marker")

  get =
    ignore(string("GET"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> optional(ignore(some_space))
    |> tag(:get)

  set =
    ignore(string("SET"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> ignore(some_space)
    |> concat(list_or_value)
    |> optional(ignore(some_space))
    |> tag(:set)

  purge =
    ignore(string("PURGE"))
    |> tag(:local)
    |> optional(ignore(some_space))
    |> tag(:purge)

  space_key =
    ignore(some_space)
    |> concat(key)

  delete_keys =
    ignore(string("DELETE"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> times(space_key, min: 0)
    |> optional(ignore(some_space))
    |> tag(:delete_keys)

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
    |> optional(local_marker)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> ignore(some_space)
    |> concat(filter)
    |> optional(ignore(some_space))
    |> tag(:create_index)

  delete_index =
    ignore(string("DELETE"))
    |> ignore(some_space)
    |> optional(local_marker)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> optional(ignore(some_space))
    |> tag(:delete_index)

  fetch_index =
    ignore(string("FETCH"))
    |> ignore(some_space)
    |> optional(local_marker)
    |> ignore(string("INDEX"))
    |> ignore(some_space)
    |> concat(index_name)
    |> optional(ignore(some_space))
    |> tag(:fetch_index)

  lpush =
    ignore(string("LPUSH"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> ignore(some_space)
    |> concat(value)
    |> optional(ignore(some_space))
    |> tag(:lpush)

  lpop =
    ignore(string("LPOP"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> optional(ignore(some_space))
    |> tag(:lpop)

  left_direction =
    ignore(string("LEFT"))
    |> tag(:left)

  right_direction =
    ignore(string("RIGHT"))
    |> tag(:right)

  direction =
    choice([
      left_direction,
      right_direction
    ])

  lmove =
    ignore(string("LMOVE"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> ignore(some_space)
    |> concat(key)
    |> ignore(some_space)
    |> concat(direction)
    |> ignore(some_space)
    |> concat(direction)
    |> optional(ignore(some_space))
    |> tag(:lmove)

  llen =
    ignore(string("LLEN"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> optional(ignore(some_space))
    |> tag(:llen)

  ltrim =
    ignore(string("LTRIM"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> ignore(some_space)
    |> optional(integer(min: 1) |> ignore(some_space))
    |> integer(min: 1)
    |> optional(ignore(some_space))
    |> tag(:ltrim)

  rpush =
    ignore(string("RPUSH"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> ignore(some_space)
    |> concat(value)
    |> optional(ignore(some_space))
    |> tag(:rpush)

  rpop =
    ignore(string("RPOP"))
    |> tag(:local)
    |> ignore(some_space)
    |> concat(key)
    |> optional(ignore(some_space))
    |> tag(:rpop)

  list_operation =
    choice([
      lpush,
      lpop,
      lmove,
      llen,
      ltrim,
      rpush,
      rpop
    ])

  command =
    optional(local_marker)
    |> choice([
      get,
      set,
      purge,
      delete_keys,
      create_index,
      delete_index,
      fetch_index,
      list_operation
    ])

  defparsec(:parse, command)

  def parse_and_put_opts(raw_command) do
    case parse(raw_command) do
      {:error, _reason, _rest, _context, _line, _column} = err ->
        Logger.debug("Failed to parse: #{raw_command}, #{inspect(err)}")
        {:error, :bad_args}

      {:ok, [parsed_command], "", _context, _line, _column} ->
        parsed_command
        |> put_opts(raw_command)

      {:ok, [{:local, []}, parsed_command], "", _context, _line, _column} ->
        parsed_command

      {:ok, _acc, rest, _context, _line, _column} ->
        Logger.debug("Not empty rest: #{inspect(rest)}")
        {:error, :not_empty_rest}
    end
  end

  defp put_opts({command, args}, raw_command) do
    new_args = drop_flags_values(args)

    if local?(new_args) do
      {command, drop_local(new_args)}
    else
      [
        local: {command, new_args},
        global: to_local_raw(raw_command),
        type: global_type(command)
      ]
    end
  end

  defp local?([:local | _args]), do: true
  defp local?(_args), do: false

  defp drop_local([:local | args]), do: args

  defp drop_flags_values(args) do
    Enum.map(args, fn arg ->
      case arg do
        {flag, []} -> flag
        _ -> arg
      end
    end)
  end

  defp to_local_raw(raw_command) do
    "LOCAL #{raw_command}"
  end

  defp global_type(:fetch_index), do: :concat
  defp global_type(_), do: :ok
end
