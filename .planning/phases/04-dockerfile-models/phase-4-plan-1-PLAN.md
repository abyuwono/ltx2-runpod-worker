# PLAN: Phase 4 - Dockerfile & Models

## Objective

Create Docker image with pre-baked models for RunPod serverless deployment. Include ComfyUI, LTX-2 extension, all required models, and the handler.

## Context

### Reference Implementation

The Wan 2.2 worker at `runpod/generate_video/` provides the pattern:
- Single `Dockerfile` with model downloads via wget
- `entrypoint.sh` starts ComfyUI then handler
- Models downloaded to ComfyUI model directories

### Required Models

Based on PROJECT.md and workflow analysis:

**Checkpoints** (`/ComfyUI/models/checkpoints/`):
- `ltx-2-19b-distilled.safetensors` - Fast mode
- `ltx-2-19b-dev.safetensors` - Pro mode

**Upscalers** (`/ComfyUI/models/latent_upscale_models/`):
- `ltx-2-spatial-upscaler-x2-1.0.safetensors`

**LoRAs** (`/ComfyUI/models/loras/`):
- `ltx-2-19b-distilled-lora-384.safetensors` - Required for Pro mode
- 7x Camera LoRAs: `ltx-2-19b-lora-camera-control-*.safetensors`

**Text Encoder** (`/ComfyUI/models/text_encoders/`):
- `gemma-3-12b-it-qat-q4_0-unquantized/` - Gemma 3 folder

### Download URLs (HuggingFace)

```bash
# Checkpoints
https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled.safetensors
https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-dev.safetensors

# Upscaler
https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors

# Distilled LoRA
https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-19b-distilled-lora-384.safetensors

# Camera LoRAs (7 files)
https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Static/resolve/main/ltx-2-19b-lora-camera-control-static.safetensors
https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-In/resolve/main/ltx-2-19b-lora-camera-control-dolly-in.safetensors
https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Out/resolve/main/ltx-2-19b-lora-camera-control-dolly-out.safetensors
https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Left/resolve/main/ltx-2-19b-lora-camera-control-dolly-left.safetensors
https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Dolly-Right/resolve/main/ltx-2-19b-lora-camera-control-dolly-right.safetensors
https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Jib-Up/resolve/main/ltx-2-19b-lora-camera-control-jib-up.safetensors
https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Jib-Down/resolve/main/ltx-2-19b-lora-camera-control-jib-down.safetensors

# Gemma Text Encoder (folder download)
huggingface-cli download google/gemma-3-12b-it-qat-q4_0-unquantized --local-dir /ComfyUI/models/text_encoders/gemma-3-12b-it-qat-q4_0-unquantized
```

### Workflow File Locations

Workflows need to be at container root (per handler.py):
- `/ltx2_t2v_fast_api.json`
- `/ltx2_t2v_pro_api.json`
- `/ltx2_i2v_fast_api.json`
- `/ltx2_i2v_pro_api.json`

## Tasks

### Task 1: Create Dockerfile

Create `Dockerfile` with:

1. **Base image**: Use NVIDIA CUDA image or existing ComfyUI base
2. **Install dependencies**: runpod, websocket-client, huggingface_hub
3. **Clone ComfyUI** and install requirements
4. **Install ComfyUI-LTXVideo** custom nodes
5. **Download models** using wget/huggingface-cli
6. **Copy handler and workflows** to appropriate locations

Structure:
```dockerfile
FROM nvidia/cuda:12.1-runtime-ubuntu22.04

# Install Python, pip, wget
# Clone ComfyUI
# Install ComfyUI-LTXVideo extension
# Download checkpoints
# Download upscaler
# Download LoRAs
# Download Gemma text encoder
# Copy handler.py, workflows, entrypoint.sh
```

### Task 2: Create entrypoint.sh

Create `entrypoint.sh` that:

1. Starts ComfyUI in background with `--listen`
2. Waits for ComfyUI to be ready (health check on port 8188)
3. Starts handler.py in foreground

Based on Wan 2.2 pattern but adapted for LTX-2.

### Task 3: Create extra_model_paths.yaml (if needed)

If model paths need customization, create config file for ComfyUI.

### Task 4: Update Workflow File Paths

Update handler.py `WORKFLOW_FILES` paths if they differ from current `/ltx2_*.json`.

## Verification

```bash
# Verify Dockerfile syntax
docker build --check .

# Verify all files exist
ls -la Dockerfile entrypoint.sh handler.py ltx2_*.json

# Test build locally (optional, requires GPU)
docker build -t ltx2-worker .
```

## Success Criteria

- [ ] `Dockerfile` created with all model downloads
- [ ] `entrypoint.sh` created to start ComfyUI and handler
- [ ] All 2 checkpoints included (distilled, dev)
- [ ] Spatial upscaler included
- [ ] All 8 LoRAs included (1 distilled + 7 camera)
- [ ] Gemma text encoder included
- [ ] Workflow files copied to correct location
- [ ] Handler copied to root

## Output

- `Dockerfile` - Docker build configuration
- `entrypoint.sh` - Container startup script

## Notes

- Total model size: ~50GB+ (checkpoints are large)
- Build time: 30-60 minutes due to model downloads
- RunPod deployment will need 48GB+ GPU (A6000, A100)

---
*Phase 4, Plan 1 of 1*
*Created: 2026-01-12*
