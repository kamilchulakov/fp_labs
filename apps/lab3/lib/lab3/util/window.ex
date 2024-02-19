defmodule Lab3.Util.Window do
  @moduledoc """
  Struct to operate with fixed size list.
  """

  @enforce_keys [:size]
  defstruct [:size, elements: []]

  @type t :: %__MODULE__{}

  @spec new(size :: pos_integer()) :: t()
  def new(size) do
    %__MODULE__{size: size}
  end

  def push(%__MODULE__{size: size, elements: []}, element) do
    %__MODULE__{size: size, elements: [element]}
  end

  def push(%__MODULE__{size: size, elements: elements}, element) when length(elements) < size do
    %__MODULE__{size: size, elements: elements ++ [element]}
  end

  def push(%__MODULE__{size: size, elements: [_ | tail]}, element) do
    %__MODULE__{size: size, elements: tail ++ [element]}
  end

  def full?(%__MODULE__{size: size, elements: elements}), do: length(elements) == size
end
