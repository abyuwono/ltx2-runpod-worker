# ROADMAP.md

## Milestone 1: LTX-2 RunPod Worker v1.0

### Phase 1: ComfyUI Workflows
**Goal:** Create API-ready ComfyUI workflow JSON files for T2V and I2V

Create the foundational ComfyUI workflow files based on example workflows from `ComfyUI-LTXVideo`. Convert visual workflows to API format with parameterized inputs for prompt, resolution, duration, seed, and model selection.

**Deliverables:**
- `ltx2_t2v_api.json` - Text-to-video workflow
- `ltx2_i2v_api.json` - Image-to-video workflow
- Node ID mapping documentation

**Research:** Study example workflows in `runpod/source/ComfyUI-LTXVideo/example_workflows/`

---

### Phase 2: Handler Core
**Goal:** Create the RunPod handler with basic T2V and I2V support

Implement `handler.py` following the Wan 2.2 pattern. Support Fast (distilled) and Pro (dev) modes, handle image URL/base64 input, connect to ComfyUI via WebSocket, and return base64 video output.

**Deliverables:**
- `handler.py` - RunPod serverless handler
- Input validation and error handling
- WebSocket connection to ComfyUI
- Video output encoding

**Research:** None - follow existing `runpod/generate_video/handler.py` pattern

---

### Phase 3: Camera & Quality LoRAs
**Goal:** Integrate camera controls and quality enhancement options

Add support for camera movement LoRAs (dolly, jib, static) and quality enhancements (spatial/temporal upscalers, detailer). Update workflows to conditionally apply LoRAs based on user selection.

**Deliverables:**
- Camera control LoRA integration (7 variants)
- Upscaler toggle support
- Detailer LoRA toggle
- Updated workflow files with LoRA nodes

**Research:** Study LoRA application in LTX-2 workflows

---

### Phase 4: Dockerfile & Models
**Goal:** Create Docker image with pre-baked models for RunPod deployment

Build Dockerfile that includes ComfyUI, LTX-2 extension, all required models, and the handler. Optimize for fast cold starts with pre-loaded models.

**Deliverables:**
- `Dockerfile` with multi-stage build
- Model download/baking scripts
- `start.sh` startup script
- RunPod template configuration

**Research:** None - follow existing Docker patterns

---

### Phase 5: Backend Integration
**Goal:** Integrate LTX-2 worker with Mivo backend API

Add LTX-2 model type to `/api/generations` route. Implement pricing logic based on duration/mode/resolution. Handle RunPod job submission and webhook callbacks.

**Deliverables:**
- LTX-2 generation endpoint in `routes/generations.ts`
- Pricing calculation logic
- RunPod job submission
- Webhook handler for job completion

**Research:** Study existing model integration in generations.ts

---

### Phase 6: Frontend Integration
**Goal:** Add LTX-2 to generate/studio AI Video section

Create LTX-2 model option in the AI Video generator UI. Add mode selector (Fast/Pro), resolution picker (720p/1080p), duration options, camera controls dropdown, and quality toggles.

**Deliverables:**
- LTX-2 model option in model selector
- Generation form with all options
- Credit cost display
- Progress indicator integration

**Research:** Study existing Seedance/Wan UI components

---

## Phase Summary

| Phase | Name | Goal | Research |
|-------|------|------|----------|
| 1 | ComfyUI Workflows | Create API-ready workflow JSONs | Yes |
| 2 | Handler Core | Basic T2V/I2V handler | No |
| 3 | Camera & Quality LoRAs | LoRA integration | Yes |
| 4 | Dockerfile & Models | Docker image with models | No |
| 5 | Backend Integration | API endpoint | Yes |
| 6 | Frontend Integration | Studio UI | Yes |

---
*Created: 2026-01-12*
