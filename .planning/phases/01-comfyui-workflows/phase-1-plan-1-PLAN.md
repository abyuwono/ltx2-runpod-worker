# PLAN: Phase 1 - ComfyUI Workflows

## Objective

Convert LTX-2 example workflows from visual format to API format, creating parameterized workflow JSON files for text-to-video (T2V) and image-to-video (I2V) generation.

## Context

### Source Workflows
- `runpod/source/ComfyUI-LTXVideo/example_workflows/LTX-2_T2V_Distilled_wLora.json` - Text-to-video template
- `runpod/source/ComfyUI-LTXVideo/example_workflows/LTX-2_I2V_Distilled_wLora.json` - Image-to-video template

### Reference API Format
- `runpod/generate_video/new_Wan22_api.json` - Wan 2.2 API workflow format

### Key Differences from Visual to API Format
- Visual: `{"nodes": [{"id": 5228, "type": "...", "widgets_values": [...]}]}`
- API: `{"5228": {"inputs": {...}, "class_type": "..."}}`

### Key LTX-2 Nodes
| Node Type | Purpose |
|-----------|---------|
| CheckpointLoaderSimple | Load LTX-2 model checkpoint |
| LTXVGemmaCLIPModelLoader | Load Gemma text encoder |
| LTXVGemmaEnhancePrompt | Prompt enhancement (optional) |
| LTXVConditioning | Create conditioning for generation |
| LoraLoaderModelOnly | Load camera/quality LoRAs |
| EmptyImage | Set resolution for T2V |
| LoadImage | Load input image for I2V |
| PrimitiveInt | Frame count (duration) |
| SaveVideo | Output video file |

### Parameterizable Inputs
- `prompt` - User's text prompt
- `width` / `height` - Resolution (1280x720 or 1920x1080)
- `num_frames` - Duration in frames (121=5s, 241=10s at 24fps)
- `seed` - Random seed for reproducibility
- `model_checkpoint` - Fast (distilled) or Pro (dev) model
- `camera_lora` - Camera movement LoRA (optional)

## Tasks

### Task 1: Create T2V API Workflow
**File:** `runpod/ltx2/ltx2_t2v_api.json`

1. Read the visual T2V workflow and extract node graph structure
2. Convert each node from visual format to API format:
   - Map `id` to key
   - Convert `widgets_values` to `inputs` with proper field names
   - Add `class_type` from node `type`
   - Preserve node connections (links become `["node_id", output_index]`)
3. Parameterize inputs:
   - CheckpointLoaderSimple: `model` field for checkpoint selection
   - EmptyImage: `width`, `height` fields
   - PrimitiveInt (length): `num_frames` field
   - PrimitiveStringMultiline: `prompt` field
   - Random seed input
4. Document node IDs for handler mapping

### Task 2: Create I2V API Workflow
**File:** `runpod/ltx2/ltx2_i2v_api.json`

1. Read the visual I2V workflow and extract node graph structure
2. Convert to API format (same process as T2V)
3. Additional parameterization:
   - LoadImage: `image` field for input image path
4. Ensure image preprocessing nodes are preserved
5. Document node IDs for handler mapping

### Task 3: Create Node Mapping Documentation
**File:** `runpod/ltx2/NODE_MAPPING.md`

Document the node IDs that the handler needs to modify:
- Checkpoint loader node ID
- Prompt input node ID
- Resolution nodes (width/height)
- Frame count node ID
- Seed node ID
- Image input node ID (I2V only)
- LoRA loader node IDs
- Output node ID

## Verification

```bash
# Verify JSON files are valid
python3 -c "import json; json.load(open('runpod/ltx2/ltx2_t2v_api.json'))"
python3 -c "import json; json.load(open('runpod/ltx2/ltx2_i2v_api.json'))"

# Verify required nodes exist
python3 -c "
import json
t2v = json.load(open('runpod/ltx2/ltx2_t2v_api.json'))
required = ['CheckpointLoaderSimple', 'LTXVGemmaCLIPModelLoader', 'SaveVideo']
found = [n for n in t2v.values() if n.get('class_type') in required]
print(f'Found {len(found)}/{len(required)} required nodes')
assert len(found) == len(required), 'Missing required nodes'
"

# Verify documentation exists
[ -f runpod/ltx2/NODE_MAPPING.md ] && echo "Node mapping exists"
```

## Success Criteria

- [ ] `ltx2_t2v_api.json` created with valid API format
- [ ] `ltx2_i2v_api.json` created with valid API format
- [ ] Both workflows load without JSON errors
- [ ] Required nodes present: checkpoint loader, text encoder, conditioning, save video
- [ ] Node IDs documented in NODE_MAPPING.md
- [ ] Parameterizable fields identified for handler integration

## Output

- `runpod/ltx2/ltx2_t2v_api.json`
- `runpod/ltx2/ltx2_i2v_api.json`
- `runpod/ltx2/NODE_MAPPING.md`

---
*Phase 1, Plan 1 of 1*
*Created: 2026-01-12*
