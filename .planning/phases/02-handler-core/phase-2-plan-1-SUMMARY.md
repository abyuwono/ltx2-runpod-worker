# SUMMARY: Phase 2 - Handler Core

## Outcome

**Status:** Completed

Successfully created the RunPod serverless handler (`handler.py`) for LTX-2 video generation. Supports all 4 workflow combinations (T2V/I2V × Fast/Pro) with parameter injection and camera LoRA support.

## Commits

| Hash | Type | Description |
|------|------|-------------|
| `2db0bf6` | feat | Create LTX-2 RunPod serverless handler |

## Deliverables

### Handler File

| File | Purpose | Lines |
|------|---------|-------|
| `handler.py` | RunPod serverless handler | 382 |

### Functions Implemented

| Function | Purpose |
|----------|---------|
| `to_nearest_multiple_of_32()` | LTX-2 resolution adjustment |
| `duration_to_frames()` | Convert seconds to frame count (24fps) |
| `process_input()` | Handle URL/base64/path input types |
| `download_file_from_url()` | Download image via wget |
| `save_base64_to_file()` | Decode and save base64 image |
| `queue_prompt()` | Send workflow to ComfyUI |
| `get_history()` | Get execution history |
| `get_videos()` | Wait for completion, extract video |
| `load_workflow()` | Load workflow JSON file |
| `inject_parameters()` | Update workflow nodes with params |
| `handler()` | Main RunPod handler entry point |

## Technical Implementation

### Workflow Selection

```python
WORKFLOW_FILES = {
    ('t2v', 'fast'): '/ltx2_t2v_fast_api.json',
    ('t2v', 'pro'): '/ltx2_t2v_pro_api.json',
    ('i2v', 'fast'): '/ltx2_i2v_fast_api.json',
    ('i2v', 'pro'): '/ltx2_i2v_pro_api.json',
}
```

### Node Mappings

Separate node ID mappings for each workflow type ensure correct parameter injection.

### Camera LoRA Support

7 camera movements supported:
- static, dolly_in, dolly_out, dolly_left, dolly_right, jib_up, jib_down

### Input/Output Format

**Input:**
```python
{
    "prompt": str,           # Required
    "type": "t2v"|"i2v",     # Default: t2v
    "mode": "fast"|"pro",    # Default: fast
    "width": int,            # Default: 1280
    "height": int,           # Default: 720
    "duration": int,         # 10, 15, 20 seconds
    "seed": int,             # Optional
    "camera_lora": str,      # Default: static
    "image_url": str,        # I2V only
    "image_base64": str,     # I2V only
}
```

**Output:**
```python
{"video": str}  # Base64 encoded video
# OR
{"error": str}  # Error message
```

## Verification

```
✓ Syntax check passed
✓ All 11 required functions present
✓ Frame calculation: 10s→241, 15s→361, 20s→481
✓ Resolution adjustment: 1080→1088, 1920→1920
```

## Deviations from Plan

None. All planned features implemented as specified.

## Issues Encountered

None blocking. The handler was created following the Wan 2.2 pattern with adaptations for LTX-2 requirements.

## Next Phase Dependencies

Phase 3 (Camera & Quality LoRAs) can now use:
- The handler structure for adding detailer LoRA toggle
- Understanding of LoRA injection pattern

Phase 4 (Dockerfile) will need to:
- Include handler.py in the Docker image
- Ensure workflow files are at root level (`/ltx2_*.json`)

---
*Completed: 2026-01-12*
