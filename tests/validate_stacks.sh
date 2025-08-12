#!/bin/bash

for stack in ../stacks/*/; do
    output=$(docker compose --file $stack/compose.yaml --env-file $stack/example.env config --quiet 2>&1)
    if [ -n "$output" ]; then
        echo $output
        exit 1
    fi
done
exit 0
