# PROJECT.md

## Overview

LTX-2 RunPod Serverless Worker for Mivo Platform - A video generation service using LightTricks' LTX-2 model integrated with ComfyUI, supporting text-to-video and image-to-video generation with camera controls and quality enhancement options.

## Context

This project creates a new RunPod serverless worker (`runpod/ltx2`) following the established pattern from `runpod/generate_video` (Wan 2.2). The worker will be integrated into the Mivo platform's AI Video generation studio, positioned after Seedance 1.5 Pro in the model selector.

### Reference Implementations
- `runpod/generate_video/handler.py` - Wan 2.2 worker pattern
- `runpod/source/ComfyUI-LTXVideo/example_workflows/` - LTX-2 workflow templates
- `runpod/source/ComfyUI/` - ComfyUI base installation

## Requirements

### Validated

(None yet - ship to validate)

### Active

#### Core Features
- [ ] Text-to-video (T2V) generation using LTX-2
- [ ] Image-to-video (I2V) generation with single starting image
- [ ] Fast mode using `ltx-2-19b-distilled-fp8.safetensors` (~8 steps)
- [ ] Pro mode using `ltx-2-19b-dev-fp8.safetensors` (20-40 steps)
- [ ] Support for both fp8 and full precision models

#### Resolution & Duration
- [ ] 720p landscape (1280x720) - base pricing tier
- [ ] 1080p landscape (1920x1080) - premium pricing tier
- [ ] 10 second duration - 30 credits base
- [ ] 15 second duration
- [ ] 20 second duration

#### Camera Controls (LoRAs)
- [ ] Static camera (default)
- [ ] Dolly in/out
- [ ] Dolly left/right
- [ ] Jib up/down

#### Quality Enhancements (User Toggles)
- [ ] Spatial upscaler (ltx-2-spatial-upscaler-x2-1.0.safetensors)
- [ ] Temporal upscaler (ltx-2-temporal-upscaler-x2-1.0.safetensors)
- [ ] Detailer LoRA (ltx-2-19b-ic-lora-detailer.safetensors)

#### Advanced I2V Controls (IC-LoRAs)
- [ ] Depth control (ltx-2-19b-ic-lora-depth-control.safetensors)
- [ ] Canny edge control (ltx-2-19b-ic-lora-canny-control.safetensors)
- [ ] Pose control (ltx-2-19b-ic-lora-pose-control.safetensors)

#### Integration
- [ ] RunPod handler.py following Wan 2.2 pattern
- [ ] ComfyUI workflow JSON files (T2V and I2V)
- [ ] Dockerfile with pre-baked models
- [ ] Backend integration via existing /api/generations route
- [ ] Frontend integration in generate/studio AI Video section
- [ ] Progress reporting via WebSocket (same as Wan 2.2)

### Out of Scope

- Keyframe interpolation / multi-keyframe workflows
- First-last-frame to video (FLF2V) - single image only for I2V
- Portrait/vertical video - landscape 16:9 only
- Negative prompts - LTX-2 doesn't use them
- User-adjustable CFG scale - fixed defaults

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Distilled for Fast, Dev for Pro | Clear quality/speed tradeoff for users | Pending |
| Pre-baked models in Docker | Faster cold starts for serverless | Pending |
| Camera LoRAs exposed | Gives users creative control | Pending |
| IC-LoRAs as advanced options | Power users get depth/canny/pose control | Pending |
| 16:9 only | Simplifies output, matches common use | Pending |
| Upscaling as user toggle | Lets users balance quality vs speed | Pending |

## Pricing Structure

| Duration | Fast 720p | Fast 1080p | Pro 720p | Pro 1080p |
|----------|-----------|------------|----------|-----------|
| 10s | 30 | 45 | 45 | 60 |
| 15s | 45 | 67 | 67 | 90 |
| 20s | 60 | 90 | 90 | 120 |

*Pro = 1.5x Fast, 1080p = 1.5x 720p*

## Required Models

### Checkpoints
- `ltx-2-19b-distilled-fp8.safetensors` - Fast mode
- `ltx-2-19b-dev-fp8.safetensors` - Pro mode
- `ltx-2-19b-dev.safetensors` - Pro mode (full precision option)
- `ltx-2-19b-distilled.safetensors` - Fast mode (full precision option)

### Upscalers
- `ltx-2-spatial-upscaler-x2-1.0.safetensors`
- `ltx-2-temporal-upscaler-x2-1.0.safetensors`

### LoRAs
- `ltx-2-19b-distilled-lora-384.safetensors` - Required for two-stage pipeline
- Camera controls: `ltx-2-19b-lora-camera-control-*.safetensors` (7 variants)
- IC LoRAs: `ltx-2-19b-ic-lora-*.safetensors` (4 variants)

### Text Encoder
- `gemma-3-12b-it-qat-q4_0-unquantized/` - Gemma text encoder

## Technical Notes

- LTX-2 requires 32GB+ VRAM
- No negative prompt support (unlike Wan 2.2)
- Frame rate: ~24 fps native
- Uses Gemma-3 text encoder instead of T5
- Two-stage pipeline: base generation → spatial upscale → temporal upscale

## Core Focus

**Reliability** - Stable, consistent results without failures. Proper error handling, clear status reporting, robust ComfyUI workflow.

---
*Last updated: 2026-01-12 after initialization*
