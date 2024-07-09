#!/bin/bash
cd "$(dirname -- "$(readlink -f "$0")")/.."

for dname in manager orchestrator router shell; do
    echo "Creating .env file for $dname"
    (cd "$dname" && echo "PYTHONPATH=$HOME/director/shared" > .env)
done
