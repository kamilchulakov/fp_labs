defmodule Lab4.DB.Filter do
  @moduledoc """
  Filter utils.
  """

  require Logger

  def filter(data, filter)

  def filter(data, {:more, value}) do
    Enum.filter(data, entry_filter(:integer, value: &(&1 > value)))
  end

  def filter(data, {:less, value}) do
    Enum.filter(data, entry_filter(:integer, value: &(&1 < value)))
  end

  def filter(data, {:starts_with, value}) do
    Enum.filter(data, entry_filter(:string, value: &String.starts_with?(&1, value)))
  end

  def filter(data, {:ends_with, value}) do
    Enum.filter(data, entry_filter(:string, value: &String.ends_with?(&1, value)))
  end

  def matches?(entry, filter) do
    filter([entry], filter) == [entry]
  end

  defp entry_filter(:string, value: filter) do
    fn {_, value} ->
      if is_bitstring(value) do
        filter.(value)
      else
        false
      end
    end
  end

  defp entry_filter(:integer, value: filter) do
    fn {_, value} ->
      if is_integer(value) do
        filter.(value)
      else
        Logger.debug("Not integer #{value}")
        false
      end
    end
  end
end
