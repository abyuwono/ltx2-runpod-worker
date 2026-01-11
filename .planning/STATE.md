# STATE.md

## Current State

**Milestone:** 1 - LTX-2 RunPod Worker v1.0
**Phase:** 5 - Backend Integration
**Status:** Not Started

## Progress

| Phase | Name | Status | Plans |
|-------|------|--------|-------|
| 1 | ComfyUI Workflows | Completed | 1 |
| 2 | Handler Core | Completed | 1 |
| 3 | Camera & Quality LoRAs | Completed | 1 |
| 4 | Dockerfile & Models | Completed | 1 |
| 5 | Backend Integration | Not Started | — |
| 6 | Frontend Integration | Not Started | — |

## Recent Activity

- 2026-01-12: Project initialized
- 2026-01-12: Roadmap created with 6 phases
- 2026-01-12: Phase 1 completed - 4 workflow files created
- 2026-01-12: Phase 2 completed - handler.py created
- 2026-01-12: Phase 3 completed - camera validation and docs
- 2026-01-12: Phase 4 completed - Dockerfile and entrypoint.sh created

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Detailer IC-LoRA deferred | V2V only, requires different workflow type |
| Spatial upscaler always-on | Integral to pipeline, quality benefit |
| Camera LoRAs validated | Input validation prevents errors |
| Pre-baked models in Docker | Faster cold starts, no runtime downloads |
| Full precision checkpoints | Better quality vs fp8 |

## Deployment Notes

- Docker image size: ~100GB+
- Build time: 30-60 minutes
- GPU requirement: 48GB+ VRAM
- RunPod template needed after build

---
*Last updated: 2026-01-12*
