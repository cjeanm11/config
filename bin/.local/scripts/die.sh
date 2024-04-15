#!/bin/bash

die() {
    # Check if port number is provided as argument
    if [ $# -ne 1 ]; then
        echo "Usage: $0 <port>"
    else
        # Get the port number
        port="$1"

        # Find the process listening on the specified port
        pid=$(lsof -t -i :$port)

        # Check if a process is found
        if [ -z "$pid" ]; then
            echo "No process found listening on port $port"
        else
            # Kill the process
            echo "Killing process $pid listening on port $port..."
            kill -9 $pid
        fi
    fi
}