# PLAN: Phase 2 - Handler Core

## Objective

Create the RunPod serverless handler (`handler.py`) for LTX-2 video generation, supporting both text-to-video (T2V) and image-to-video (I2V) modes with Fast (distilled) and Pro (dev) model variants.

## Context

### Reference Implementation
- `runpod/generate_video/handler.py` - Wan 2.2 handler pattern to follow

### Workflow Files (from Phase 1)
- `ltx2_t2v_fast_api.json` - T2V with distilled model
- `ltx2_t2v_pro_api.json` - T2V with dev model
- `ltx2_i2v_fast_api.json` - I2V with distilled model
- `ltx2_i2v_pro_api.json` - I2V with dev model

### Node Mappings (from NODE_MAPPING.md)

**T2V Fast:**
- Prompt: `5222.inputs.value`
- Resolution: `5217.inputs.width/height`
- Frames: `5218.inputs.value`
- Seed: `5237154.inputs.noise_seed`
- Camera LoRA: `5230.inputs.lora_name`, `5231.inputs.lora_name`

**T2V Pro:**
- Prompt: `5225.inputs.value`
- Resolution: `5232.inputs.width/height`
- Frames: `5233.inputs.value`
- Seed: `5266248.inputs.noise_seed`
- Camera LoRA: `5221.inputs.lora_name`, `5222.inputs.lora_name`

**I2V Fast:**
- Prompt: `5175.inputs.value`
- Image: `5180.inputs.image`
- Resolution: `5185.inputs.width/height`
- Frames: `5186.inputs.value`
- Seed: `5194097.inputs.noise_seed`
- Camera LoRA: `5182.inputs.lora_name`, `5183.inputs.lora_name`

**I2V Pro:**
- Prompt: `5175.inputs.value`
- Image: `5180.inputs.image`
- Resolution: `5185.inputs.width/height`
- Frames: `5186.inputs.value`
- Seed: `5194097.inputs.noise_seed`
- Camera LoRA: `5182.inputs.lora_name`, `5183.inputs.lora_name`

### Input Parameters

```python
{
    "prompt": str,              # Required: text prompt
    "mode": str,                # "fast" or "pro" (default: "fast")
    "type": str,                # "t2v" or "i2v" (default: "t2v")
    "width": int,               # 1280 or 1920 (default: 1280)
    "height": int,              # 720 or 1088 (default: 720)
    "duration": int,            # 10, 15, or 20 seconds (default: 10)
    "seed": int,                # Random seed (default: random)
    "camera_lora": str,         # Camera movement (default: "static")
    # I2V only:
    "image_url": str,           # URL to input image
    "image_base64": str,        # Base64 encoded image
}
```

### Output Format

```python
{
    "video": str  # Base64 encoded video
}
# OR on error:
{
    "error": str  # Error message
}
```

## Tasks

### Task 1: Create Handler Foundation
**File:** `handler.py`

1. Copy utility functions from Wan 2.2 handler:
   - `process_input()` - Handle URL/base64/path input
   - `download_file_from_url()` - Download image from URL
   - `save_base64_to_file()` - Save base64 image to file
   - `queue_prompt()` - Send workflow to ComfyUI
   - `get_history()` - Get execution history
   - `get_videos()` - Wait for completion and extract video
   - `load_workflow()` - Load workflow JSON

2. Create resolution adjustment function:
   - `to_nearest_multiple_of_32()` - LTX-2 requires 32-divisible dimensions

3. Create workflow selection logic:
   - Select workflow based on `type` (t2v/i2v) and `mode` (fast/pro)

4. Create frame count calculator:
   - `duration_to_frames(seconds)` - Convert duration to frame count (24fps)

### Task 2: Implement Workflow Parameter Injection

Create `inject_parameters()` function that updates workflow nodes based on input:

1. **Prompt injection** - Different node IDs per workflow
2. **Resolution injection** - Width/height with 32-multiple adjustment
3. **Frame count injection** - Convert duration to frames
4. **Seed injection** - Random if not provided
5. **Camera LoRA injection** - Map camera name to LoRA file
6. **Image injection** (I2V only) - Set image path in LoadImage node

Use node mapping dictionary per workflow type.

### Task 3: Implement Main Handler

Create `handler(job)` function:

1. **Parse input** - Extract and validate parameters
2. **Process image** (I2V) - Download/decode input image
3. **Select workflow** - Based on type and mode
4. **Inject parameters** - Update workflow nodes
5. **Connect to ComfyUI** - HTTP health check then WebSocket
6. **Execute workflow** - Queue and wait for completion
7. **Return result** - Base64 video or error

Include proper error handling and logging throughout.

## Verification

```bash
# Verify handler.py exists and has no syntax errors
python3 -m py_compile handler.py && echo "Syntax OK"

# Verify required functions exist
python3 -c "
from handler import handler, load_workflow, inject_parameters, duration_to_frames
print('All required functions found')
"

# Verify workflow loading
python3 -c "
from handler import load_workflow
wf = load_workflow('/ltx2_t2v_fast_api.json')
print(f'Loaded workflow with {len(wf)} nodes')
"
```

## Success Criteria

- [ ] `handler.py` created with no syntax errors
- [ ] Utility functions copied and adapted from Wan 2.2
- [ ] Resolution adjustment uses 32-multiple (not 16)
- [ ] Workflow selection works for all 4 combinations (t2v/i2v × fast/pro)
- [ ] Parameter injection updates correct node IDs per workflow
- [ ] Camera LoRA mapping implemented
- [ ] Frame count calculation correct (24fps)
- [ ] Image input handling for I2V mode
- [ ] Error handling and logging present

## Output

- `handler.py` - RunPod serverless handler for LTX-2

---
*Phase 2, Plan 1 of 1*
*Created: 2026-01-12*
