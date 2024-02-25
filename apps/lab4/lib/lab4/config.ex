defmodule Lab4.Config do
  require Logger

  alias Lab4.Config

  @enforce_keys [:shards, :data_dir, :port]
  defstruct [:shards, :data_dir, :port]

  def new(path: path, data_dir: data_dir, port: port, shard: shard) do
    transforms = [Config.MapToShard, Config.ShardListToShardsInfo]

    shards =
      Toml.decode_file!(path, keys: :atoms, transforms: transforms)
      |> Map.get(:shards)
      |> Config.ShardsInfo.apply_current(shard)

    Logger.info("Parsed shards")
    Logger.debug(inspect(shards))

    %__MODULE__{
      shards: shards,
      data_dir: data_dir,
      port: port
    }
  end
end

defmodule Lab4.Config.Shard do
  @enforce_keys [:name, :index]
  defstruct [:name, :index]
end

defmodule Lab4.Config.ShardsInfo do
  @enforce_keys [:list, :count]
  defstruct [:list, :count, :current]

  def new(shards) do
    %__MODULE__{
      list: shards,
      count: max(Enum.count(shards), Enum.max_by(shards, & &1.index).index + 1)
    }
  end

  def apply_current(shards_info, shard) do
    shards_info
    |> struct(current: Enum.find(shards_info.list, &(&1.name == shard)))
  end
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

defmodule Lab4.Config.ShardListToShardsInfo do
  use Toml.Transform

  def transform(:shards, v) when is_list(v) do
    Lab4.Config.ShardsInfo.new(v)
  end

  def transform(_k, v), do: v
end
