# PLAN: Phase 3 - Camera & Quality LoRAs

## Objective

Finalize LoRA integration documentation and evaluate quality enhancement options. Camera LoRAs are already implemented in Phase 2; this phase documents that work and addresses remaining quality features.

## Context

### Current State

**Already Implemented (Phase 2):**
- Camera LoRA injection in handler.py (7 variants)
- Dual LoRA loader nodes per workflow (camera_lora_1, camera_lora_2)
- CAMERA_LORAS mapping dict

**Quality Features Analysis:**

| Feature | Status | Notes |
|---------|--------|-------|
| Camera LoRAs | Done | 7 variants implemented |
| Spatial Upscaler | Always-on | Built into workflow pipeline |
| Temporal Upscaler | Not used | Would need workflow changes |
| Detailer IC-LoRA | V2V only | Requires video input, not applicable to T2V/I2V |

### Key Findings

1. **Detailer IC-LoRA** (`ltx-2-19b-ic-lora-detailer.safetensors`) is for Video-to-Video refinement workflows. The example workflow (`LTX-2_V2V_Detailer.json`) takes an existing video, processes it, and outputs a refined version. This is a post-generation feature, not applicable to T2V/I2V generation.

2. **Spatial Upscaler** is integral to the two-stage pipeline in all workflows. The `LTXVLatentUpsampler` node (e.g., 5237187) is deeply connected to the generation flow. Making it optional would require creating alternative workflow branches.

3. **Camera LoRAs** work by injecting into two `LoraLoaderModelOnly` nodes per workflow. This is already handled by `inject_parameters()`.

### Recommendation

Given that:
- Camera LoRAs are fully implemented
- Detailer is for V2V (different use case)
- Upscaler is already integrated and adds quality

**Phase 3 should:**
1. Document the implemented camera controls
2. Add input validation for camera_lora parameter
3. Defer V2V/detailer to a future milestone
4. Keep upscaler always-on (it's beneficial)

## Tasks

### Task 1: Validate Camera LoRA Implementation

Verify handler.py properly handles all camera options:

```python
# Expected camera options
camera_options = ['static', 'dolly_in', 'dolly_out', 'dolly_left', 'dolly_right', 'jib_up', 'jib_down']
```

1. Check CAMERA_LORAS dict completeness
2. Add input validation to reject invalid camera_lora values
3. Log warning for unknown camera options (fallback to static)

### Task 2: Update Handler Input Validation

Enhance handler.py to validate camera_lora input:

```python
# Add to handler() function after extracting camera_lora
valid_cameras = list(CAMERA_LORAS.keys())
if camera_lora not in valid_cameras:
    logger.warning(f"Unknown camera_lora '{camera_lora}', using 'static'")
    camera_lora = "static"
```

### Task 3: Update Documentation

1. Update NODE_MAPPING.md with camera LoRA usage notes
2. Add section explaining which LoRAs are supported

## Verification

```bash
# Verify handler has camera validation
grep -n "camera_lora" handler.py

# Verify all 7 camera options are mapped
python3 -c "
from handler import CAMERA_LORAS
expected = ['static', 'dolly_in', 'dolly_out', 'dolly_left', 'dolly_right', 'jib_up', 'jib_down']
missing = [c for c in expected if c not in CAMERA_LORAS]
if missing:
    print(f'Missing cameras: {missing}')
else:
    print('All 7 camera options present')
"
```

## Success Criteria

- [ ] All 7 camera LoRA options mapped correctly
- [ ] Invalid camera_lora input handled gracefully (fallback to static)
- [ ] Documentation updated with camera usage notes
- [ ] No breaking changes to existing API

## Output

- Updated `handler.py` with camera validation
- Updated `NODE_MAPPING.md` documentation

## Scope Notes

**Deferred to future milestone:**
- V2V Detailer workflow (requires video input handling)
- Temporal upscaler (not in current workflows)
- Upscaler toggle (always-on is beneficial for quality)

---
*Phase 3, Plan 1 of 1*
*Created: 2026-01-12*
