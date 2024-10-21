#!/bin/bash

die() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 <port>"
    else
        port="$1"
        pid=$(lsof -t -i :$port)
        if [ -z "$pid" ]; then
            echo "No process found listening on port $port"
        else
            echo "Killing process $pid listening on port $port..."
            kill -9 $pid
        fi
    fi
}
