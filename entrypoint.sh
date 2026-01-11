#!/bin/bash

# LTX-2 RunPod Worker Entrypoint
# Starts ComfyUI and then the RunPod handler

set -e

echo "========================================="
echo "LTX-2 RunPod Worker Starting..."
echo "========================================="

# Start ComfyUI in the background
echo "Starting ComfyUI..."
python /ComfyUI/main.py --listen --port 8188 &

# Wait for ComfyUI to be ready
echo "Waiting for ComfyUI to be ready..."
max_wait=180  # 3 minutes max
wait_count=0

while [ $wait_count -lt $max_wait ]; do
    if curl -s http://127.0.0.1:8188/ > /dev/null 2>&1; then
        echo "ComfyUI is ready! (took ${wait_count}s)"
        break
    fi

    # Show progress every 10 seconds
    if [ $((wait_count % 10)) -eq 0 ] && [ $wait_count -gt 0 ]; then
        echo "Still waiting for ComfyUI... (${wait_count}s/${max_wait}s)"
    fi

    sleep 1
    wait_count=$((wait_count + 1))
done

if [ $wait_count -ge $max_wait ]; then
    echo "ERROR: ComfyUI failed to start within ${max_wait} seconds"
    exit 1
fi

# Start the RunPod handler in the foreground
echo "Starting RunPod handler..."
exec python /handler.py
