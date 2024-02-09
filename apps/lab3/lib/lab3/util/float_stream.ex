defmodule Lab3.Util.FloatStream do
  @moduledoc """
  ## Reasons:
  - https://stackoverflow.com/questions/34383303/range-of-floating-point-numbers
  """

  @spec new(from :: float(), to :: float(), step :: float()) :: Enumerable.t(float())
  def new(from, to, step) do
    from
    |> Stream.iterate(&(&1 + step))
    |> Stream.take_while(&(&1 <= to))
    |> Enum.to_list()
  end
end
