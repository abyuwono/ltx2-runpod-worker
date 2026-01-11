# PLAN: Phase 6 - Frontend Integration

## Objective

Add LTX-2 Text-to-Video and Image-to-Video models to the AI Video generator in `/generate/studio`. Support Fast/Pro modes, 720p/1080p resolution, 10/15/20s duration, and 7 camera LoRA options.

## Context

### Reference Implementation

The existing AI Video UI follows a consistent pattern:
- **File:** `frontend/src/app/generate/studio/page.tsx` (8,990 lines)
- **Model Grid:** Lines 5738-5847 - inline model definitions with selection limits
- **Task Options:** Lines 5850-6073 - per-task dropdowns for duration, resolution, quality, etc.
- **Credits Display:** Lines 6075-6115 - inline credit calculation with model-specific pricing
- **Submit Handler:** Lines 2174-2325 - validation, prompt enhancement, API call

### LTX-2 Specifications

From STATE.md and backend integration:

**Models:**
- `ltx-2-t2v` - Text-to-Video (no image required)
- `ltx-2-i2v` - Image-to-Video (1 image required)

**Options:**
- Quality: `fast` | `pro`
- Resolution: `720p` (1280x720) | `1080p` (1920x1088)
- Duration: `10` | `15` | `20` seconds
- Camera LoRA: `static` | `dolly_in` | `dolly_out` | `dolly_left` | `dolly_right` | `jib_up` | `jib_down`
- Seed: Any number (supports reproducibility)

**Pricing (credits):**
| Duration | Fast 720p | Fast 1080p | Pro 720p | Pro 1080p |
|----------|-----------|------------|----------|-----------|
| 10s | 30 | 45 | 45 | 68 |
| 15s | 45 | 68 | 68 | 102 |
| 20s | 60 | 90 | 90 | 135 |

Formula: `base * (1 + 0.5*isPro) * (1 + 0.5*is1080p)`
- 10s base = 30, 15s base = 45, 20s base = 60

### Task State Interface

```typescript
interface AiVideoTask {
  id: string;
  model: 'ltx-2-t2v' | 'ltx-2-i2v' | ... ;
  aspectRatio: '16:9' | '9:16';  // LTX-2 landscape only initially
  duration: number;
  quality?: 'fast' | 'pro';  // LTX-2 uses this
  resolution?: '720p' | '1080p';
  seed?: number;
  cameraLora?: string;  // NEW: LTX-2 only
}
```

### API Request Format (from backend)

```typescript
{
  model: 'ltx-2-t2v' | 'ltx-2-i2v',
  prompt: string,
  quality: 'fast' | 'pro',
  resolution: '720p' | '1080p',
  duration: 10 | 15 | 20,
  camera_lora: 'static' | 'dolly_*' | 'jib_*',
  seed?: number,
  image_urls?: string[]  // I2V only
}
```

## Tasks

### Task 1: Add LTX-2 Model Entries to Model Grid

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location:** Lines 5739-5746 (model array)

Add two entries after `wan-2.2-remix`:

```typescript
{ id: 'ltx-2-t2v', name: 'LTX-2', price: '30-135 cr', duration: '10-20s', maxImages: 0, supportsI2v: false, maxJobs: 5, requiresImage: false },
{ id: 'ltx-2-i2v', name: 'LTX-2 I2V', price: '30-135 cr', duration: '10-20s', maxImages: 1, supportsI2v: true, maxJobs: 5, requiresImage: true },
```

Update default values in click handler (around line 5788):
- Duration: 10
- Quality: 'fast'
- Resolution: '720p'
- Seed: Random number
- CameraLora: 'static'
- AspectRatio: '16:9' (LTX-2 is landscape by default)

### Task 2: Add LTX-2 Model Name Display

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location:** Lines 5870-5877 (task model name display)

Add LTX-2 model name mapping:
```typescript
{task.model === 'ltx-2-t2v' && 'LTX-2'}
{task.model === 'ltx-2-i2v' && 'LTX-2 I2V'}
```

### Task 3: Add LTX-2 Task Options UI

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location:** After Wan 2.2 resolution selector (around line 6038)

Add LTX-2 specific options:

1. **Duration selector** (10s/15s/20s)
2. **Resolution selector** (720p/1080p)
3. **Quality selector** (Fast/Pro)
4. **Camera LoRA selector** (7 options)
5. **Seed input** (already exists pattern at line 6041)

```tsx
{/* LTX-2 Options */}
{(task.model === 'ltx-2-t2v' || task.model === 'ltx-2-i2v') && (
  <>
    {/* Duration */}
    <select value={task.duration} onChange={...}>
      <option value={10}>10s</option>
      <option value={15}>15s</option>
      <option value={20}>20s</option>
    </select>

    {/* Resolution */}
    <select value={task.resolution} onChange={...}>
      <option value="720p">720p</option>
      <option value="1080p">1080p</option>
    </select>

    {/* Quality */}
    <select value={task.quality} onChange={...}>
      <option value="fast">Fast</option>
      <option value="pro">Pro</option>
    </select>

    {/* Camera */}
    <select value={task.cameraLora || 'static'} onChange={...}>
      <option value="static">Static</option>
      <option value="dolly_in">Dolly In</option>
      <option value="dolly_out">Dolly Out</option>
      <option value="dolly_left">Dolly Left</option>
      <option value="dolly_right">Dolly Right</option>
      <option value="jib_up">Jib Up</option>
      <option value="jib_down">Jib Down</option>
    </select>
  </>
)}
```

### Task 4: Add LTX-2 Credit Calculation

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location 1:** Function `calculateAiVideoCredits()` (around line 2155)
**Location 2:** Inline credits display (around line 6080)

Add pricing logic:
```typescript
else if (task.model === 'ltx-2-t2v' || task.model === 'ltx-2-i2v') {
  // Base: 30 for 10s, 45 for 15s, 60 for 20s
  let base = 30
  if (task.duration === 15) base = 45
  else if (task.duration >= 20) base = 60
  // Pro mode: +50%
  if (task.quality === 'pro') base = Math.ceil(base * 1.5)
  // 1080p: +50%
  if (task.resolution === '1080p') base = Math.ceil(base * 1.5)
  total += base
}
```

### Task 5: Update API Request Mapping

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location:** Lines 2227-2248 (tasks mapping in handleCreateAiVideo)

Add LTX-2 specific fields to request:
```typescript
const tasks = aiVideoModels.map(m => {
  // ... existing code ...

  return {
    model: m.model,
    prompt: finalPrompt,
    aspect_ratio: m.aspectRatio,
    duration: m.duration,
    quality: m.quality,
    resolution: m.resolution,
    seed: m.seed,
    image_urls: modelImageUrls.length > 0 ? modelImageUrls : undefined,
    template: aiVideoTemplate || undefined,
    multi_shots: m.model === 'wan-2.6' ? m.multiShots : undefined,
    camera_lora: (m.model === 'ltx-2-t2v' || m.model === 'ltx-2-i2v') ? (m.cameraLora || 'static') : undefined,  // NEW
  }
})
```

### Task 6: Update Type Definitions (if needed)

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location:** State type definitions (early in file)

Add `cameraLora` to task interface if explicit types exist.

### Task 7: Add LTX-2 to Aspect Ratio Handler

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location:** Aspect ratio selector (around line 5880)

LTX-2 supports 16:9 and 9:16 (standard landscape/portrait):
```tsx
{(task.model === 'ltx-2-t2v' || task.model === 'ltx-2-i2v') && (
  <select value={task.aspectRatio} onChange={...}>
    <option value="16:9">16:9</option>
    <option value="9:16">9:16</option>
  </select>
)}
```

### Task 8: Update Seed Input Condition

**File:** `frontend/src/app/generate/studio/page.tsx`
**Location:** Seed input condition (around line 6041)

Add LTX-2 to seed support:
```typescript
{(task.model.includes('veo') || task.model === 'wan-2.6' || task.model === 'wan-2.2-remix' || task.model === 'seedance-1.5-pro' || task.model === 'ltx-2-t2v' || task.model === 'ltx-2-i2v') && (
  <input type="number" ... />
)}
```

## Verification

```bash
# Verify TypeScript compiles
cd frontend && npm run build

# Check for LTX-2 references
grep -n "ltx-2" src/app/generate/studio/page.tsx

# Count occurrences (should be ~15-20)
grep -c "ltx-2" src/app/generate/studio/page.tsx
```

## Success Criteria

- [ ] LTX-2 T2V and I2V appear in model selector grid
- [ ] Model selection creates tasks with correct defaults
- [ ] Duration (10/15/20), resolution (720p/1080p), quality (fast/pro) selectable
- [ ] Camera LoRA dropdown with 7 options
- [ ] Seed input available for LTX-2 tasks
- [ ] Credits display correct values (30-135 range)
- [ ] Submit sends `camera_lora` field in API request
- [ ] I2V model requires image upload
- [ ] Frontend builds without TypeScript errors

## Output

- Modified `frontend/src/app/generate/studio/page.tsx` - LTX-2 UI integration

## Dependencies

- Backend Phase 5 complete (API ready)
- RunPod worker not required for frontend testing (will queue jobs)

---
*Phase 6, Plan 1 of 1*
*Created: 2026-01-12*
