defmodule Lab3.Config do
  defstruct window: 1

  def new(args) do
    case OptionParser.parse(args, strict: [window: :integer]) do
      {[window: window], _, _} -> %__MODULE__{window: window}
      _ -> %__MODULE__{}
    end
  end
end
