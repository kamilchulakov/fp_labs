# Lab4

## Task
Implement redis (int, string, list), index (distributed), sharding, replica (in user query)

## Design
Simplicity is reliability (c) [Yuriy Nasretdinov][Yuriy Nasretdinov] [(SovietReliable)][SovietReliable]

### CAP
<img src="./assets/cap_databases.png" width="400px"/>

`Redis` is CP system, so I don't care about availability of my system...

### Static sharding
`SERVER("KEY") = HASH("KEY") % NUM_OF_SHARDS`

### Local database
- I think `HashMap` as store for this particular task kinda sucks.
- Implementing my own `B+ tree` makes laboratory work too hard.
- So I want something like `boltdb`, but in Elixir: [CubDB](https://github.com/lucaong/cubdb)

### HTTP server
- Every node in cluster is equal.
- So any node can redirect to correct shard.

Endpoints:
- get
- set
- ???
- ?replicate?

### CMD
No ideas yet

### Config
- name
- index
- adress
- replicas

## Worth to mention
- [Chordy](https://people.kth.se/~johanmon/dse/chordy.pdf)
- [Yuriy Nasretdinov][Yuriy Nasretdinov]
- [His 'distribkv' in Go playlist](https://www.youtube.com/playlist?list=PLWwSgbaBp9XrMkjEhmTIC37WX2JfwZp7I)
- [Crafting a Database Engine: how DBs do what they do by Luca Ongaro (CubDB) | Ruby User Group Berlin](https://www.youtube.com/watch?v=fSgoeKJ06B4)
- [Всё, что вы не знали о CAP теореме | Хабр](https://habr.com/ru/articles/328792/)

[Yuriy Nasretdinov]: https://github.com/YuriyNasretdinov
[SovietReliable]: https://www.youtube.com/@SovietReliable