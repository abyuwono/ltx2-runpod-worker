# SUMMARY: Phase 1 - ComfyUI Workflows

## Outcome

**Status:** Completed

Successfully converted LTX-2 example workflows from ComfyUI visual format to API format. Created 4 workflow files (T2V/I2V x Fast/Pro) and comprehensive node mapping documentation.

## Commits

| Hash | Type | Description |
|------|------|-------------|
| `147bb95` | feat | Create LTX-2 ComfyUI API workflows (4 files) |
| `4495bc2` | docs | Add node mapping documentation |

## Deliverables

### Workflow Files Created

| File | Type | Mode | Nodes |
|------|------|------|-------|
| `ltx2_t2v_fast_api.json` | Text-to-Video | Fast (Distilled) | 41 |
| `ltx2_t2v_pro_api.json` | Text-to-Video | Pro (Dev) | 45 |
| `ltx2_i2v_fast_api.json` | Image-to-Video | Fast (Distilled) | 47 |
| `ltx2_i2v_pro_api.json` | Image-to-Video | Pro (Dev) | 51 |

### Documentation

- `NODE_MAPPING.md` - Complete node ID reference for handler integration

## Technical Findings

### Workflow Structure

The example workflows contained packed "subgraph" nodes (UUID-based types) that needed to be flattened. The conversion:

1. Extracted subgraph definitions from `definitions.subgraphs[]`
2. Flattened inner nodes with offset IDs (parent_id * 1000 + inner_id)
3. Converted visual format (`nodes[]` with `widgets_values`) to API format (`{node_id: {class_type, inputs}}`)

### Key Node Differences Between Modes

| Feature | Fast (Distilled) | Pro (Dev) |
|---------|------------------|-----------|
| Checkpoint | `ltx-2-19b-distilled.safetensors` | `ltx-2-19b-dev.safetensors` |
| Frame count default | 121 (5s) | 241 (10s) |
| Extra LoRA | None | `ltx-2-19b-distilled-lora-384.safetensors` |
| Node count | 41-47 | 45-51 |

### LTX-2 Specific Notes

- Uses Gemma-3 text encoder (not T5 like Wan 2.2)
- No negative prompt support
- Frame rate: 24 fps
- Resolution must be divisible by 32 (hence 1088 instead of 1080)
- Dual LoRA loader nodes for camera controls

## Deviations from Plan

1. **Additional workflows**: Originally planned 2 files (T2V + I2V), expanded to 4 files (Fast/Pro variants) based on structural differences between Distilled and Dev workflows.

2. **Subgraph flattening**: Required custom conversion logic to handle packed workflow nodes - not anticipated in original plan.

## Issues Encountered

None blocking. The subgraph complexity was handled during execution.

## Next Phase Dependencies

Phase 2 (Handler Core) can now use:
- Workflow files with known node IDs
- NODE_MAPPING.md for parameter injection points
- Understanding that checkpoint, VAE, and audio VAE nodes must be updated together

---
*Completed: 2026-01-12*
