defmodule Lab4.Config do
  require Logger

  alias Lab4.Config

  defstruct [:shards, :data_dir, port: 8080]

  def new(args) do
    strict_args = [port: :integer, sharding_file: :string, shard: :string, data_dir: :string]
    {parsed_args, _, _} = OptionParser.parse(args, strict: strict_args)

    apply_args(port: parsed_args[:port])
    |> apply_args(sharding_file: parsed_args[:sharding_file], shard: parsed_args[:shard])
    |> apply_args(data_dir: parsed_args[:data_dir])
  end

  defp apply_args(config \\ %__MODULE__{}, args)

  defp apply_args(config, port: nil), do: config
  defp apply_args(config, port: port) do
    struct(config, port: port)
  end

  defp apply_args(config, sharding_file: path, shard: shard) do
    struct(config, shards: parse_shards(path, shard))
  end

  defp apply_args(_, data_dir: nil) do
    raise "--data-dir is required"
  end

  defp apply_args(config, data_dir: path) do
    struct(config, data_dir: path)
  end

  defp parse_shards(path, shard) do
    if path == nil do
      raise "--sharding-file is required"
    end

    if shard == nil do
      raise "--shard is required"
    end

    transforms = [Config.MapToShard, Config.ShardListToShardsInfo]

    shards =
      Toml.decode_file!(path, keys: :atoms, transforms: transforms)
      |> Map.get(:shards)
      |> Config.ShardsInfo.apply_current(shard)

    Logger.info("Parsed shards")
    Logger.debug(inspect(shards))

    shards
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
