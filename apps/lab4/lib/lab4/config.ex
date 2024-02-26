defmodule Lab4.Config do
  require Logger

  alias Lab4.Config

  defstruct [:shards, :data_dir, :port, :replica]

  def new(args) do
    strict_args = [
      sharding_file: :string,
      shard: :string,
      data_dir: :string,
      port: :integer,
      replica: :boolean
    ]

    {parsed_args, _, _} = OptionParser.parse(args, strict: strict_args)

    apply_args(port: parsed_args[:port])
    |> apply_args(sharding_file: parsed_args[:sharding_file], shard: parsed_args[:shard])
    |> apply_args(data_dir: parsed_args[:data_dir])
    |> apply_args(replica: parsed_args[:replica])
  end

  defp apply_args(config \\ %__MODULE__{}, args)

  defp apply_args(_, port: nil) do
    raise "--port is required"
  end

  defp apply_args(config, replica: true) do
    struct(config, replica: true)
  end

  defp apply_args(config, replica: nil) do
    struct(config, replica: false)
  end

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

    Logger.info("Parsed shards", shard: shards.current.index)
    Logger.debug(inspect(shards))

    shards
  end
end

defmodule Lab4.Config.Shard do
  @enforce_keys [:name, :index, :address, :replicas]
  defstruct [:name, :index, :address, :replicas]
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
      index: v[:index],
      address: String.to_integer(v[:address]),
      replicas: v[:replicas]
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
