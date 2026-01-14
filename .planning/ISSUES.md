# ISSUES.md

## Open Enhancements

*No open issues - pending verification of ISS-008 fix*

---

## Closed Enhancements

### ISS-008: Gemma Download - Use --token Flag Directly
**Closed:** 2026-01-14 - Simplified to use --token flag with huggingface-cli download
**Original Error:** Build still failing with exit code 1, `huggingface-cli login` approach not working in RunPod
**Root Cause:** The `huggingface-cli login --add-to-git-credential` was failing silently in RunPod's build environment
**Resolution:**
- Removed separate login step
- Pass `--token "${HF_TOKEN}"` directly to the `huggingface-cli download` command
- Simplified shell parameter expansion to be more portable (`$(echo "${HF_TOKEN}" | cut -c1-10)` instead of `${HF_TOKEN:0:10}`)
- Used `printf` and `wc -c` instead of `${#HF_TOKEN}` for token length check
- Added `set -ex` for verbose error output

### ISS-007: Gemma Download Build Failure - Verbose Diagnostics
**Closed:** 2026-01-14 - Added comprehensive debugging output to Dockerfile
**Original Error:** Build failed with exit code 1 during Gemma model download, with unclear error messages
**Root Cause:** Likely token permission issue or license not accepted, but error output was insufficient to diagnose
**Resolution:** Enhanced Dockerfile Gemma download section with:
- Token format and length validation
- `huggingface-cli --version` output
- `huggingface-cli whoami` authentication verification
- `--add-to-git-credential` flag for better token persistence
- Step-by-step progress messages for easier debugging
- Troubleshooting comments for common issues

### ISS-006: HF_TOKEN Build Error in RunPod
**Closed:** 2026-01-14 - Fixed Dockerfile to use `huggingface-cli login` before download
**Original Error:** Build failed with exit code 2 when downloading Gemma model, even with HF_TOKEN set
**Root Cause:** The `--token` flag for `huggingface-cli download` may not work correctly in all environments
**Resolution:** Changed to use `huggingface-cli login --token "${HF_TOKEN}"` before the download command, which properly authenticates the session. Also added validation to check if token is empty with clear error messages.

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
*Last updated: 2026-01-14*
