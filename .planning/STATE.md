# STATE.md

## Current State

**Milestone:** 1 - LTX-2 RunPod Worker v1.0
**Phase:** Completed
**Status:** Milestone Complete

## Progress

| Phase | Name | Status | Plans |
|-------|------|--------|-------|
| 1 | ComfyUI Workflows | Completed | 1 |
| 2 | Handler Core | Completed | 1 |
| 3 | Camera & Quality LoRAs | Completed | 1 |
| 4 | Dockerfile & Models | Completed | 1 |
| 5 | Backend Integration | Completed | 1 |
| 6 | Frontend Integration | Completed | 1 |

## Recent Activity

- 2026-01-12: Project initialized
- 2026-01-12: Roadmap created with 6 phases
- 2026-01-12: Phase 1 completed - 4 workflow files created
- 2026-01-12: Phase 2 completed - handler.py created
- 2026-01-12: Phase 3 completed - camera validation and docs
- 2026-01-12: Phase 4 completed - Dockerfile and entrypoint.sh created
- 2026-01-12: Phase 5 completed - Backend integration (provider, pricing, handler)
- 2026-01-12: Phase 6 completed - Frontend UI integration
- 2026-01-12: **Milestone 1 complete** - Ready for deployment
- 2026-01-15: Fixed ISS-010 - ARG HF_TOKEN scope issue in Dockerfile
- 2026-01-16: Fixed ISS-011 - Switched to Docker BuildKit secrets for HF_TOKEN
- 2026-01-18: Fixed ISS-012 - Reverted to --build-arg for RunPod compatibility
- 2026-01-18: Fixed ISS-013 - Moved Gemma download to runtime (final solution)

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Detailer IC-LoRA deferred | V2V only, requires different workflow type |
| Spatial upscaler always-on | Integral to pipeline, quality benefit |
| Camera LoRAs validated | Input validation prevents errors |
| Pre-baked models in Docker | Faster cold starts, no runtime downloads |
| Full precision checkpoints | Better quality vs fp8 |
| Separate RunPod provider | Clean separation from WAN provider |
| AiVideoTask interface extended | Type safety for LTX-2 camera_lora field |

## Deployment Notes

- Docker image size: ~100GB+
- Build time: 30-60 minutes
- GPU requirement: 48GB+ VRAM
- RunPod template needed after build
- Backend env: `RUNPOD_LTX_ENDPOINT_ID` required

## API Reference

**Endpoint:** `POST /api/generations/studio/ai-video`

**LTX-2 Task:**
```json
{
  "model": "ltx-2-t2v" | "ltx-2-i2v",
  "prompt": "string",
  "quality": "fast" | "pro",
  "resolution": "720p" | "1080p",
  "duration": 10 | 15 | 20,
  "camera_lora": "static" | "dolly_*" | "jib_*",
  "seed": number (optional),
  "image_urls": ["url"] (I2V only)
}
```

## Deployment Checklist

- [ ] Accept Gemma license: https://huggingface.co/google/gemma-3-12b-it-qat-q4_0-unquantized
- [ ] Deploy to RunPod via GitHub integration:
  - Repository: Point to this repo
  - Environment Variables: `HF_TOKEN=hf_xxx` (your HuggingFace token)
  - **Note:** First cold start downloads Gemma (~25GB, 5-10 min). Use network volume to cache.
- [ ] Set `RUNPOD_LTX_ENDPOINT_ID` in backend environment
- [ ] Test T2V generation through UI
- [ ] Test I2V generation through UI
- [ ] Verify webhook callback works
- [ ] Monitor first few jobs for errors

---
*Last updated: 2026-01-18*
