#!/bin/bash

# LTX-2 RunPod Worker Entrypoint
# Downloads Gemma model if needed, starts ComfyUI, and runs the RunPod handler

set -e

echo "========================================="
echo "LTX-2 RunPod Worker Starting..."
echo "========================================="

# Download Gemma model if not present (runtime download for RunPod compatibility)
GEMMA_DIR="/ComfyUI/models/text_encoders/gemma-3-12b-it-qat-q4_0-unquantized"
if [ ! -d "$GEMMA_DIR" ] || [ -z "$(ls -A $GEMMA_DIR 2>/dev/null)" ]; then
    echo ""
    echo "========================================="
    echo "Downloading Gemma Model (one-time setup)"
    echo "========================================="
    echo ""

    if [ -z "${HF_TOKEN}" ]; then
        echo "ERROR: HF_TOKEN environment variable is required"
        echo ""
        echo "Set HF_TOKEN in your RunPod template environment variables:"
        echo "  HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        echo ""
        echo "Get token from: https://huggingface.co/settings/tokens"
        echo "Accept license: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized"
        exit 1
    fi

    echo "Token provided: $(echo "${HF_TOKEN}" | cut -c1-10)..."
    echo "Model: google/gemma-3-12b-it-qat-q4_0-unquantized (~25GB)"
    echo "This will take several minutes on first startup..."
    echo ""

    huggingface-cli download google/gemma-3-12b-it-qat-q4_0-unquantized \
        --local-dir "$GEMMA_DIR" \
        --local-dir-use-symlinks False \
        --token "${HF_TOKEN}" || {
        echo ""
        echo "======================================================="
        echo "DOWNLOAD FAILED"
        echo "======================================================="
        echo ""
        echo "Most likely cause: LICENSE NOT ACCEPTED"
        echo ""
        echo "1. Go to: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized"
        echo "2. Click 'Agree and access repository'"
        echo "3. Restart this worker"
        echo ""
        exit 1
    }

    echo ""
    echo "Gemma download complete!"
    echo ""
else
    echo "Gemma model already present, skipping download"
fi

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
