# Lab4

## Task
Implement redis (int, string, list), index (distributed), sharding, replica (in user query)

## Questions
- distrubuted index?
- demo instead of test?
- do we really need types?
- how many replicas can be?

## Design
Simplicity is reliability (c) [Yuriy Nasretdinov][Yuriy Nasretdinov] [(SovietReliable)][SovietReliable]

### CAP
<img src="./assets/cap_databases.png" width="400px"/>

`Redis` is CP system, so I don't care about availability of my system...

### Static sharding
- `SERVER("KEY") = HASH("KEY") % NUM_OF_SHARDS`
- resharding by x2
- just do purge

### Local database
- I think `HashMap` as store for this particular task kinda sucks.
- Implementing my own `B+ tree` makes laboratory work too hard.
- So I want something like `boltdb`, but in Elixir: [CubDB](https://github.com/lucaong/cubdb)

### HTTP server
- Every node in cluster is equal.
- So any node can redirect to correct shard.

(TODO:)
Single endpoint handling json:
- generic operations: get/set/copy/del
- list operations
- cluster operations: replicate, slaves...

Trust me, `Plug` is trash.

### CMD
```sh
mix escript.build
./lab4 --sharding-file conf/sharding.toml --shard Saint-Petersburg --data-dir db/spb
```

You can find launch and kill scripts in `scripts` folder.

Maybe better to provide local socket address for each shard and global accessible in sharding config file, but I keep my lab simple... 

### Config
- [TOML library](https://hex.pm/packages/toml/0.7.0)
- Each shard:
    - name
    - index
    - port
    - replicas

### Redis is hard :(
- https://redis.io/docs/data-types/lists/

## Worth to mention
- [Chordy](https://people.kth.se/~johanmon/dse/chordy.pdf)
- [Yuriy Nasretdinov][Yuriy Nasretdinov]
- [His 'distribkv' in Go playlist](https://www.youtube.com/playlist?list=PLWwSgbaBp9XrMkjEhmTIC37WX2JfwZp7I)
- [Crafting a Database Engine: how DBs do what they do by Luca Ongaro (CubDB) | Ruby User Group Berlin](https://www.youtube.com/watch?v=fSgoeKJ06B4)
- [Всё, что вы не знали о CAP теореме | Хабр](https://habr.com/ru/articles/328792/)

[Yuriy Nasretdinov]: https://github.com/YuriyNasretdinov
[SovietReliable]: https://www.youtube.com/@SovietReliable

## Yuriy Guides
- no `log fatal` in library code
- static sharding = if you decided to live in Moscow, you can't never go anywhere else
