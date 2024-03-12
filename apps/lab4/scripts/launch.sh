mix escript.build

./lab4 --port 8080 --sharding-file conf/sharding.toml --shard Saint-Petersburg --data-dir db/spb &
./lab4 --port 8084 --sharding-file conf/sharding.toml --shard Saint-Petersburg --replica --data-dir db/spb-replica &
./lab4 --port 8081 --sharding-file conf/sharding.toml --shard Moscow --data-dir db/moscow &
