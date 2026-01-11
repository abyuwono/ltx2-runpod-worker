# NODE_MAPPING.md

Node ID reference for LTX-2 ComfyUI API workflows. The handler uses these IDs to inject parameters into the workflow before execution.

## Workflow Files

| File | Mode | Type | Nodes |
|------|------|------|-------|
| `ltx2_t2v_fast_api.json` | Fast (Distilled) | Text-to-Video | 41 |
| `ltx2_t2v_pro_api.json` | Pro (Dev) | Text-to-Video | 45 |
| `ltx2_i2v_fast_api.json` | Fast (Distilled) | Image-to-Video | 47 |
| `ltx2_i2v_pro_api.json` | Pro (Dev) | Image-to-Video | 51 |

## Node ID Reference

### T2V Fast (`ltx2_t2v_fast_api.json`)

| Parameter | Node ID | Field | Default Value |
|-----------|---------|-------|---------------|
| **Prompt** | `5222` | `inputs.value` | (user input) |
| **Checkpoint** | `5228` | `inputs.ckpt_name` | `ltx-2-19b-distilled.safetensors` |
| **Width** | `5217` | `inputs.width` | 1920 |
| **Height** | `5217` | `inputs.height` | 1088 |
| **Frame Count** | `5218` | `inputs.value` | 121 |
| **Camera LoRA 1** | `5230` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Camera LoRA 2** | `5231` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Seed** | `5237154` | `inputs.noise_seed` | 420 |
| **Gemma VAE** | `5227` | `inputs.vae_name` | `ltx-2-19b-distilled.safetensors` |
| **Audio VAE** | `5219` | `inputs.model_name` | `ltx-2-19b-distilled.safetensors` |
| **Spatial Upscaler** | `5244` | `inputs.model_name` | `ltx-2-spatial-upscaler-x2-1.0.safetensors` |

### T2V Pro (`ltx2_t2v_pro_api.json`)

| Parameter | Node ID | Field | Default Value |
|-----------|---------|-------|---------------|
| **Prompt** | `5225` | `inputs.value` | (user input) |
| **Checkpoint** | `5220` | `inputs.ckpt_name` | `ltx-2-19b-dev.safetensors` |
| **Width** | `5232` | `inputs.width` | 1920 |
| **Height** | `5232` | `inputs.height` | 1088 |
| **Frame Count** | `5233` | `inputs.value` | 241 |
| **Camera LoRA 1** | `5221` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Camera LoRA 2** | `5222` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Distilled LoRA** | `5216` | `inputs.lora_name` | `ltx-2-19b-distilled-lora-384.safetensors` |
| **Seed** | `5266248` | `inputs.noise_seed` | 420 |
| **Gemma VAE** | `5218` | `inputs.vae_name` | `ltx-2-19b-dev.safetensors` |
| **Audio VAE** | `5219` | `inputs.model_name` | `ltx-2-19b-dev.safetensors` |
| **Spatial Upscaler** | `5270` | `inputs.model_name` | `ltx-2-spatial-upscaler-x2-1.0.safetensors` |

### I2V Fast (`ltx2_i2v_fast_api.json`)

| Parameter | Node ID | Field | Default Value |
|-----------|---------|-------|---------------|
| **Prompt** | `5175` | `inputs.value` | (user input) |
| **Input Image** | `5180` | `inputs.image` | (user input) |
| **Checkpoint** | `5176` | `inputs.ckpt_name` | `ltx-2-19b-distilled.safetensors` |
| **Width** | `5185` | `inputs.width` | 1920 |
| **Height** | `5185` | `inputs.height` | 1088 |
| **Frame Count** | `5186` | `inputs.value` | 121 |
| **Camera LoRA 1** | `5182` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Camera LoRA 2** | `5183` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Seed** | `5194097` | `inputs.noise_seed` | 420 |
| **Gemma VAE** | `5178` | `inputs.vae_name` | `ltx-2-19b-distilled.safetensors` |
| **Audio VAE** | `5188` | `inputs.model_name` | `ltx-2-19b-distilled.safetensors` |
| **Spatial Upscaler** | `5210` | `inputs.model_name` | `ltx-2-spatial-upscaler-x2-1.0.safetensors` |

### I2V Pro (`ltx2_i2v_pro_api.json`)

| Parameter | Node ID | Field | Default Value |
|-----------|---------|-------|---------------|
| **Prompt** | `5175` | `inputs.value` | (user input) |
| **Input Image** | `5180` | `inputs.image` | (user input) |
| **Checkpoint** | `5176` | `inputs.ckpt_name` | `ltx-2-19b-dev.safetensors` |
| **Width** | `5185` | `inputs.width` | 1280 |
| **Height** | `5185` | `inputs.height` | 704 |
| **Frame Count** | `5186` | `inputs.value` | 121 |
| **Camera LoRA 1** | `5182` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Camera LoRA 2** | `5183` | `inputs.lora_name` | `your_camera_lora.safetensors` |
| **Distilled LoRA** | `5199` | `inputs.lora_name` | `ltx-2-19b-distilled-lora-384.safetensors` |
| **Seed** | `5194097` | `inputs.noise_seed` | 420 |
| **Gemma VAE** | `5178` | `inputs.vae_name` | `ltx-2-19b-dev.safetensors` |
| **Audio VAE** | `5188` | `inputs.model_name` | `ltx-2-19b-dev.safetensors` |
| **Spatial Upscaler** | `5212` | `inputs.model_name` | `ltx-2-spatial-upscaler-x2-1.0.safetensors` |

## Frame Count Reference

LTX-2 runs at 24 fps. Frame count formula: `frames = seconds * 24 + 1`

| Duration | Frames |
|----------|--------|
| 5 seconds | 121 |
| 10 seconds | 241 |
| 15 seconds | 361 |
| 20 seconds | 481 |

## Resolution Reference

LTX-2 requires dimensions divisible by 32. Supported landscape resolutions:

| Resolution | Width | Height |
|------------|-------|--------|
| 720p | 1280 | 720 |
| 1080p | 1920 | 1088 |

Note: 1088 (not 1080) for height due to 32-divisibility requirement.

## Camera LoRA Reference

The handler accepts `camera_lora` parameter with these values:

| API Value | Movement | LoRA File |
|-----------|----------|-----------|
| `static` | Static camera (default) | `ltx-2-19b-lora-camera-control-static.safetensors` |
| `dolly_in` | Move camera forward | `ltx-2-19b-lora-camera-control-dolly-in.safetensors` |
| `dolly_out` | Move camera backward | `ltx-2-19b-lora-camera-control-dolly-out.safetensors` |
| `dolly_left` | Move camera left | `ltx-2-19b-lora-camera-control-dolly-left.safetensors` |
| `dolly_right` | Move camera right | `ltx-2-19b-lora-camera-control-dolly-right.safetensors` |
| `jib_up` | Tilt camera up | `ltx-2-19b-lora-camera-control-jib-up.safetensors` |
| `jib_down` | Tilt camera down | `ltx-2-19b-lora-camera-control-jib-down.safetensors` |

### Usage

```json
{
  "prompt": "A serene mountain landscape",
  "camera_lora": "dolly_in"
}
```

Invalid values fall back to `static` with a warning logged.

### Supported LoRAs Summary

| LoRA Type | Status | Notes |
|-----------|--------|-------|
| Camera Control (7) | Supported | All dolly/jib movements |
| Distilled LoRA | Auto | Applied in Pro mode workflows |
| Spatial Upscaler | Always-on | Built into pipeline |
| Detailer IC-LoRA | Not supported | V2V only (future feature) |
| Depth/Canny/Pose IC-LoRAs | Not supported | Advanced I2V (future feature) |

## Handler Implementation Notes

When updating workflow nodes, ensure consistency across related nodes:

1. **Checkpoint changes**: Update `CheckpointLoaderSimple`, `LTXVGemmaCLIPModelLoader.vae_name`, and `LTXVAudioVAELoader.model_name` together
2. **Resolution changes**: Update `EmptyImage` width/height
3. **Camera LoRA**: Both LoRA loader nodes should use the same camera LoRA
4. **Pro mode**: Includes an additional `LoraLoaderModelOnly` node for distilled LoRA

---
*Generated: 2026-01-12*
