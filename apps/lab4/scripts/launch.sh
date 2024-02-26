mix escript.build

./lab4 --sharding-file conf/sharding.toml --shard Saint-Petersburg --data-dir db/spb &
./lab4 --sharding-file conf/sharding.toml --shard Moscow --data-dir db/moscow &
