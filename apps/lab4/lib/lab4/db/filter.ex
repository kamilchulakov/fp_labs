defmodule Lab4.DB.Filter do
  def filter(data, filter)

  def filter(data, {:more, value}) do
    Stream.filter(data, entry_filter(value: &(&1 > value)))
  end

  def filter(data, {:less, value}) do
    Stream.filter(data, entry_filter(value: &(&1 < value)))
  end

  def filter(data, {:starts_with, value}) do
    Stream.filter(data, entry_filter(value: &String.starts_with?(&1, value)))
  end

  def filter(data, {:ends_with, value}) do
    Stream.filter(data, entry_filter(value: &String.ends_with?(&1, value)))
  end

  def matches?(entry, filter) do
    filter([entry], filter) == [entry]
  end

  defp entry_filter(value: filter) do
    fn {_, value} -> filter.(value) end
  end
end
