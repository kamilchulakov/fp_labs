#!/bin/bash

for shard in localhost:8080 localhost:8081 localhost:8082 localhost:8083; do
    curl "http://$shard/purge"
    echo -e " $shard"
done