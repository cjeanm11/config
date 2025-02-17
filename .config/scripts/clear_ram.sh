#!/bin/bash

function clear_ram() {
    echo "Clearing RAM cache..."
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
    sleep 5
}

while true; do
    clear_ram
done
