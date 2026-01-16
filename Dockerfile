# syntax=docker/dockerfile:1
# LTX-2 RunPod Serverless Worker
# Includes ComfyUI, LTX-2 extension, and pre-baked models

FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3.10-venv \
    git \
    wget \
    curl \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    pip install "huggingface_hub[hf_transfer]" runpod websocket-client

# Enable HF transfer for faster downloads
ENV HF_HUB_ENABLE_HF_TRANSFER=1

WORKDIR /

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install -r requirements.txt

# Install ComfyUI-LTXVideo extension
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git && \
    cd ComfyUI-LTXVideo && \
    pip install -r requirements.txt

# Install additional useful extensions
RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite && \
    cd ComfyUI-VideoHelperSuite && \
    pip install -r requirements.txt

# Create model directories
RUN mkdir -p /ComfyUI/models/checkpoints \
    /ComfyUI/models/loras \
    /ComfyUI/models/latent_upscale_models \
    /ComfyUI/models/text_encoders

# Download LTX-2 Checkpoints (~38GB each for full precision)
RUN wget -q --show-progress -O /ComfyUI/models/checkpoints/ltx-2-19b-distilled.safetensors \
    https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled.safetensors

RUN wget -q --show-progress -O /ComfyUI/models/checkpoints/ltx-2-19b-dev.safetensors \
    https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-dev.safetensors

# Download Spatial Upscaler
RUN wget -q --show-progress -O /ComfyUI/models/latent_upscale_models/ltx-2-spatial-upscaler-x2-1.0.safetensors \
    https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors

# Download Distilled LoRA (required for Pro mode two-stage pipeline)
RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-distilled-lora-384.safetensors \
    https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors

# Download Camera Control LoRAs (7 variants)
RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-static.safetensors \
    https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Static/resolve/main/ltx-2-19b-lora-camera-control-static.safetensors

RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-dolly-in.safetensors \
    https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-In/resolve/main/ltx-2-19b-lora-camera-control-dolly-in.safetensors

RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-dolly-out.safetensors \
    https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Out/resolve/main/ltx-2-19b-lora-camera-control-dolly-out.safetensors

RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-dolly-left.safetensors \
    https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Left/resolve/main/ltx-2-19b-lora-camera-control-dolly-left.safetensors

RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-dolly-right.safetensors \
    https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Right/resolve/main/ltx-2-19b-lora-camera-control-dolly-right.safetensors

RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-jib-up.safetensors \
    https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Jib-Up/resolve/main/ltx-2-19b-lora-camera-control-jib-up.safetensors

RUN wget -q --show-progress -O /ComfyUI/models/loras/ltx-2-19b-lora-camera-control-jib-down.safetensors \
    https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Jib-Down/resolve/main/ltx-2-19b-lora-camera-control-jib-down.safetensors

# Download Gemma Text Encoder (requires HF authentication + license acceptance)
# Uses Docker BuildKit secrets for secure token handling
#
# IMPORTANT: Gemma is a GATED MODEL - you must accept the license BEFORE building!
#
# SETUP STEPS:
# 1. Get a HuggingFace token: https://huggingface.co/settings/tokens
# 2. Accept Gemma license: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized
#    (Click "Agree and access repository" - approval is immediate)
# 3. Build with:
#    export HF_TOKEN=hf_xxx
#    docker buildx build --secret id=HF_TOKEN,env=HF_TOKEN -t ltx2-worker .
#
# ALTERNATIVE (if BuildKit secrets not available):
#    echo "hf_xxx" > /tmp/hf_token.txt
#    docker buildx build --secret id=HF_TOKEN,src=/tmp/hf_token.txt -t ltx2-worker .
#    rm /tmp/hf_token.txt
#
# TROUBLESHOOTING:
# - "403 Forbidden" or "Access denied": You haven't accepted the Gemma license
# - "401 Unauthorized": Token is invalid or doesn't have read permissions
# - Token format should be: hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (37+ chars)
# - "could not find HF_TOKEN": BuildKit not enabled or secret not passed correctly
#
RUN --mount=type=secret,id=HF_TOKEN,required=true \
    set -ex && \
    echo "=== HuggingFace Token Validation ===" && \
    HF_TOKEN=$(cat /run/secrets/HF_TOKEN) && \
    if [ -z "${HF_TOKEN}" ]; then \
        echo ""; \
        echo "ERROR: HF_TOKEN secret is empty"; \
        echo ""; \
        echo "Usage: docker buildx build --secret id=HF_TOKEN,env=HF_TOKEN ..."; \
        echo ""; \
        echo "Get token from: https://huggingface.co/settings/tokens"; \
        echo ""; \
        exit 1; \
    fi && \
    echo "Token provided: $(echo "${HF_TOKEN}" | cut -c1-10)..." && \
    TOKEN_LEN=$(printf '%s' "${HF_TOKEN}" | wc -c | tr -d ' ') && \
    echo "Token length: ${TOKEN_LEN} characters" && \
    if [ "${TOKEN_LEN}" -lt 30 ]; then \
        echo "ERROR: Token appears too short. HF tokens are typically 37+ characters."; \
        exit 1; \
    fi && \
    echo "" && \
    echo "=== HuggingFace CLI Version ===" && \
    huggingface-cli --version && \
    echo "" && \
    echo "=== Downloading Gemma Model ===" && \
    echo "Model: google/gemma-3-12b-it-qat-q4_0-unquantized (GATED)" && \
    echo "This may take a while (~25GB)..." && \
    echo "" && \
    huggingface-cli download google/gemma-3-12b-it-qat-q4_0-unquantized \
        --local-dir /ComfyUI/models/text_encoders/gemma-3-12b-it-qat-q4_0-unquantized \
        --local-dir-use-symlinks False \
        --token "${HF_TOKEN}" || \
    { \
        echo ""; \
        echo "======================================================="; \
        echo "DOWNLOAD FAILED - Most likely cause: LICENSE NOT ACCEPTED"; \
        echo "======================================================="; \
        echo ""; \
        echo "Gemma is a GATED model. Before building, you must:"; \
        echo ""; \
        echo "1. Log into HuggingFace with the account that owns this token"; \
        echo "2. Go to: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized"; \
        echo "3. Click 'Agree and access repository' to accept Google's terms"; \
        echo "4. Re-run this build"; \
        echo ""; \
        echo "Other possible causes:"; \
        echo "- Token doesn't have 'Read' permission for gated repos"; \
        echo "- Token is invalid or expired"; \
        echo ""; \
        exit 1; \
    } && \
    echo "" && \
    echo "=== Gemma Download Complete ==="

# Copy handler, workflows, and entrypoint
COPY handler.py /handler.py
COPY ltx2_t2v_fast_api.json /ltx2_t2v_fast_api.json
COPY ltx2_t2v_pro_api.json /ltx2_t2v_pro_api.json
COPY ltx2_i2v_fast_api.json /ltx2_i2v_fast_api.json
COPY ltx2_i2v_pro_api.json /ltx2_i2v_pro_api.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8188/ || exit 1

CMD ["/entrypoint.sh"]
