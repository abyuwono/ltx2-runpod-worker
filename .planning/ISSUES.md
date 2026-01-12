# ISSUES.md

## Open Enhancements

None

---

## Closed Enhancements

### ISS-005: Remove "Landscape only" label
**Closed:** 2026-01-12 - Simplified aspect ratio label
**Original Issue:** Label showed "16:9 (Landscape only)" which is verbose
**Resolution:** Changed to just "16:9"

### ISS-004: Merge LTX-2 T2V and I2V models
**Closed:** 2026-01-12 - Unified into single model with auto-detect
**Original Issue:** Two separate models (LTX-2 and LTX-2 I2V) in selector
**Resolution:** Merged into single "LTX-2" model. Backend auto-detects T2V vs I2V based on image presence.

### ISS-003: LTX-2 Aspect Ratio Display
**Closed:** 2026-01-12 - Fixed UI to show only 16:9 landscape option
**Original Issue:** LTX-2 showed both 16:9 and 9:16 options but only landscape is supported
**Resolution:** Removed 9:16 option

### ISS-002: HuggingFace Authentication for Gemma Model
**Closed:** 2026-01-12 - Fixed by adding HF_TOKEN build argument to Dockerfile
**Original Error:** Build failed at line 102 - `google/gemma-3-12b-it-qat-q4_0-unquantized` requires authentication
**Resolution:** Added `ARG HF_TOKEN` and `--token ${HF_TOKEN}` to Dockerfile. Build with: `--build-arg HF_TOKEN=your_token`

### ISS-001: Add LTX-2 test client file
**Closed:** 2026-01-12 - User decision: Will deploy manually without test client
**Original Note:** Existing serverless endpoints have `*_client.py` files (z_image_client.py, generate_video_client.py)
**Resolution:** Test client is optional (for debugging only). Backend provider handles API calls.

---
*Last updated: 2026-01-12*
