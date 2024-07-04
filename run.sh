#!/bin/bash
# Function to cleanly shut down processes
cleanup() {
    echo "Caught Signal... terminating Apache ($APACHE_PID) and patchman ($PATCHMAN_PID) gracefully!"
    # Kill the Apache process
    kill -TERM $APACHE_PID
    # Kill the patchman process
    kill -TERM $PATCHMAN_PID
    exit 0
}

# Trap SIGTERM, SIGINT and exit signals
trap cleanup SIGTERM SIGINT EXIT

echo "running migrations..."
patchman-manage migrate

echo "Starting Apache2..."
# Starts apache2ctl in the foreground
apache2ctl -D FOREGROUND &

# Apache process ID
APACHE_PID=$!

# Function to run patchman in the background periodically
run_patchman() {
    while true; do
        # Run patchman command
        patchman -a
        # Wait for 10min (600 seconds) before running again
        sleep 600
    done
}

echo "starting patchman processing loop..."
# Start the patchman function in the background
run_patchman &

# Capture the process ID of the background job
PATCHMAN_PID=$!

# Wait for Apache to exit
wait $APACHE_PID

# Once Apache exits, kill the background patchman job if still running
kill $PATCHMAN_PID

