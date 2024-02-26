mix escript.build

./lab4 --sharding-file conf/sharding.toml --shard Saint-Petersburg --data-dir db/spb --port 8081 &
./lab4 --sharding-file conf/sharding.toml --shard Moscow --data-dir db/moscow --port 8082 &
./lab4 --sharding-file conf/sharding.toml --shard Kazan --data-dir db/kazan --port 8083 &

