defmodule Lab4.Config do
  require Logger
  @enforce_keys [:shards, :data_dir]
  defstruct [:shards, :data_dir]

  def new(path: path, data_dir: data_dir) do
    transforms = [Lab4.Config.MapToShard]
    shards = Toml.decode_file!(path, keys: :atoms, transforms: transforms)[:shards]

    Logger.info("Parsed shards")
    Logger.debug(inspect(shards))

    %__MODULE__{shards: shards, data_dir: data_dir}
  end
end

defmodule Lab4.Config.Shard do
  @enforce_keys [:name, :index]
  defstruct [:name, :index]
end

defmodule Lab4.Config.MapToShard do
  use Toml.Transform

  def transform(:shards, v) when is_map(v) do
    %Lab4.Config.Shard{
      name: v[:name],
      index: v[:index]
    }
  end
  def transform(_k, v), do: v
end
