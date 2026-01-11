# PLAN: Phase 5 - Backend Integration

## Objective

Integrate LTX-2 video generation with the Mivo backend API. Add model type, pricing logic, RunPod job submission, and webhook handling to enable LTX-2 video generation from the frontend.

## Context

### Reference Implementation

The Wan 2.2 RunPod integration provides the pattern:
- **Provider:** `backend/src/services/providers/runpodWan.ts`
- **Routes:** `backend/src/routes/generations.ts`
- **Pricing:** Fixed credits based on resolution
- **Webhook:** Reuses existing RunPod webhook handler

### LTX-2 Input/Output

**Handler Input (from handler.py):**
```python
{
    "prompt": str,              # Required
    "type": "t2v" | "i2v",      # Default: t2v
    "mode": "fast" | "pro",     # Default: fast
    "width": int,               # Default: 1280
    "height": int,              # Default: 720
    "duration": int,            # 10, 15, 20 seconds
    "seed": int,                # Optional
    "camera_lora": str,         # Default: static
    "image_url": str,           # I2V only
    "image_base64": str,        # I2V only
}
```

**Handler Output:**
```python
{"video": str}  # Base64 encoded video
# OR
{"error": str}  # Error message
```

### Pricing Structure (from PROJECT.md)

| Duration | Fast 720p | Fast 1080p | Pro 720p | Pro 1080p |
|----------|-----------|------------|----------|-----------|
| 10s | 30 | 45 | 45 | 60 |
| 15s | 45 | 67 | 67 | 90 |
| 20s | 60 | 90 | 90 | 120 |

Formula: `base = 30 credits for 10s@720p`, `+50% for Pro`, `+50% for 1080p`, `+50% per 5s`

### Environment Variables Needed

```bash
RUNPOD_LTX_ENDPOINT_ID=<endpoint-id>  # New env var for LTX-2 endpoint
```

## Tasks

### Task 1: Create RunPod LTX-2 Provider

**File:** `backend/src/services/providers/runpodLtx.ts`

Create provider module following `runpodWan.ts` pattern:

```typescript
export interface RunPodLtxJobInput {
  prompt: string;
  type: 't2v' | 'i2v';
  mode: 'fast' | 'pro';
  width: number;
  height: number;
  duration: number;
  seed?: number;
  camera_lora?: string;
  image_url?: string;
}

export async function createJob(input: RunPodLtxJobInput): Promise<RunPodCreateResult>
export async function getJobStatus(runpodJobId: string): Promise<RunPodStatusResult>
export async function getEndpointHealth(): Promise<RunPodHealthResult>
```

### Task 2: Add LTX-2 Pricing Logic

**File:** `backend/src/routes/generations.ts`

Add to `computeChargedCredits()` function (around line 142):

```typescript
// LTX-2 Video pricing
else if (videoModel === 'ltx-2-t2v' || videoModel === 'ltx-2-i2v') {
  // Base: 30 credits for 10s@720p Fast
  let base = 30;

  // Duration multiplier
  if (duration === 15) base = 45;
  else if (duration === 20) base = 60;

  // Mode multiplier (Pro = 1.5x)
  if (mode === 'pro') base = Math.ceil(base * 1.5);

  // Resolution multiplier (1080p = 1.5x)
  if (resolution === '1080p') base = Math.ceil(base * 1.5);

  totalCredits += base;
}
```

### Task 3: Add LTX-2 Generation Handler

**File:** `backend/src/routes/generations.ts`

Add LTX-2 handling in Studio AI Video endpoint (POST `/api/generations/studio/ai-video`):

```typescript
} else if (videoModel === 'ltx-2-t2v' || videoModel === 'ltx-2-i2v') {
  providerType = 'runpod';
  providerModel = videoModel;

  // Map resolution to dimensions
  const isLandscape = aspectRatio === '16:9';
  let width, height;
  if (resolution === '1080p') {
    width = 1920; height = 1088;  // 32-divisible
  } else {
    width = 1280; height = 720;
  }

  const ltxInput: RunPodLtxJobInput = {
    prompt,
    type: videoModel === 'ltx-2-i2v' ? 'i2v' : 't2v',
    mode: task.quality === 'pro' ? 'pro' : 'fast',
    width,
    height,
    duration: task.duration || 10,
    seed: task.seed,
    camera_lora: task.camera_lora || 'static',
    ...(imageUrl && { image_url: imageUrl }),
  };

  const created = await runpodLtxProvider.createJob(ltxInput);
  providerJobId = created.runpodJobId;
  runpodPoller.addJob(created.runpodJobId);
}
```

### Task 4: Update Webhook Handler

**File:** `backend/src/routes/generations.ts`

The existing RunPod webhook handler should work with LTX-2 output format (base64 video), but verify and update if needed:

```typescript
// In handleRunPodWebhook()
// LTX-2 returns { video: base64 } format
if (output?.video && !videoUrl) {
  videoUrl = await uploadBase64VideoToR2(output.video, String(job._id));
}
```

### Task 5: Add Environment Variable

**File:** `backend/.env.example` (if exists) or document

```bash
# LTX-2 RunPod Configuration
RUNPOD_LTX_ENDPOINT_ID=<your-ltx2-endpoint-id>
```

## Verification

```bash
# Verify provider file created
ls backend/src/services/providers/runpodLtx.ts

# Verify TypeScript compiles
cd backend && npm run build

# Search for LTX-2 references
grep -r "ltx-2" backend/src/
```

## Success Criteria

- [ ] `runpodLtx.ts` provider created
- [ ] Pricing logic for 6 price tiers (2 modes × 3 durations)
- [ ] Generation handler processes LTX-2 requests
- [ ] Webhook handles LTX-2 video output
- [ ] Environment variable documented
- [ ] TypeScript compiles without errors

## Output

- `backend/src/services/providers/runpodLtx.ts` - LTX-2 RunPod provider
- Modified `backend/src/routes/generations.ts` - Pricing and generation handling

## Dependencies

- RunPod endpoint must be deployed before testing
- Endpoint ID needed in environment

---
*Phase 5, Plan 1 of 1*
*Created: 2026-01-12*
