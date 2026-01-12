# ISSUES.md

## Open Enhancements

None

---

## Closed Enhancements

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
