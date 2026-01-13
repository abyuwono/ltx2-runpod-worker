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

# HuggingFace token for gated models (pass at build time: --build-arg HF_TOKEN=xxx)
ARG HF_TOKEN

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

# Download Gemma Text Encoder (requires HF authentication)
# Must pass --build-arg HF_TOKEN=hf_xxx when building
# Token must have access to: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized
RUN if [ -z "${HF_TOKEN}" ]; then \
        echo "ERROR: HF_TOKEN build argument is required for Gemma model download"; \
        echo "Usage: docker build --build-arg HF_TOKEN=hf_xxx ..."; \
        echo "Get token from: https://huggingface.co/settings/tokens"; \
        echo "Accept license at: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized"; \
        exit 1; \
    fi && \
    huggingface-cli login --token "${HF_TOKEN}" && \
    huggingface-cli download google/gemma-3-12b-it-qat-q4_0-unquantized \
        --local-dir /ComfyUI/models/text_encoders/gemma-3-12b-it-qat-q4_0-unquantized \
        --local-dir-use-symlinks False

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
