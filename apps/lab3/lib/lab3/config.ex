defmodule Lab3.Config do
  @moduledoc """
  Struct to store config.
  """

  @enforce_keys [:step]
  defstruct [:step, window: 5, separator: " "]

  def new(args) do
    case OptionParser.parse(args, strict: [window: :integer, step: :float]) do
      {[window: window, step: step], _, _} -> %__MODULE__{window: window, step: step}
      {[step: step], _, _} -> %__MODULE__{step: step}
      _ -> raise "--step <value> is missing"
    end
  end
end
