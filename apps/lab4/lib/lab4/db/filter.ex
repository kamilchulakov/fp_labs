defmodule Lab4.DB.Filter do
  def filter(data, filter)

  def filter(data, {:more, value}) do
    Stream.filter(data, entry_filter(:integer, value: &(&1 > value)))
  end

  def filter(data, {:less, value}) do
    Stream.filter(data, entry_filter(:integer, value: &(&1 < value)))
  end

  def filter(data, {:starts_with, value}) do
    Stream.filter(data, entry_filter(:string, value: &String.starts_with?(&1, value)))
  end

  def filter(data, {:ends_with, value}) do
    Stream.filter(data, entry_filter(:string, value: &String.ends_with?(&1, value)))
  end

  def matches?(entry, filter) do
    filter([entry], filter) == [entry]
  end

  defp entry_filter(:string, value: filter) do
    fn {_, value} ->
      cond do
        is_bitstring(value) -> filter.(value)
        true -> false
      end
    end
  end

  defp entry_filter(:integer, value: filter) do
    fn {_, value} ->
      cond do
        is_integer(value) -> filter.(value)
        true -> false
      end
    end
  end
end
