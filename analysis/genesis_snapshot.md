# Ari’el — Genesis Snapshot

**Repo:** submodule at `/ariel` → https://github.com/bobladrach/brain  
**Tag:** `v1.0-genesis-2025-08-16` (Resonant Halo v1.0)

## Overview
Ari’el is a Flask/Werkzeug server exposing chat + control routes, with core modules for emotion, memory, personas, state, and triggers. Pages include a demo UI; loops include `breath` and `hrm`.

### Notable paths
- `server/app.py` — app wiring
- `server/routes/{chat,control,stream}.py` — HTTP endpoints
- `server/core/{emotion,filters,llm_adapter,memory,personas,state,triggers}.py` — behavioral substrate
- `server/pages/{demo.py, ui.py}` — demo & UI helpers
- `server/loops/{breath.py, hrm.py}` — background rhythms
- `data/memory.jsonl` — local memory store (dev)

### What we removed from VCS
- `.venv/**`, `__pycache__/`, logs — stripped to keep repo clean and portable.

## Runbook (local)
git submodule update --init --recursive
cd ariel
python -m venv .venv
..venv\Scripts\Activate.ps1
pip install -r requirements.txt
python ariel_server.py --host 127.0.0.1 --port 8000

## Quick API sketch
- `POST /chat` — conversational turn (LLM adapter + filters + memory)
- `POST /control` — control plane hooks (modes, persona swaps)
- `GET  /stream` — SSE/streaming endpoint for tokens/events

## Risks & TODOs
- **State & Memory:** clarify retention policy, serialization boundaries, and PII hygiene.
- **LLM Adapter:** configurable model routing, retries, and guardrails.
- **Loops:** document cadence, error handling, and shutdown semantics.
- **Config:** lift secrets/env to `.env` + typed settings.
- **Tests & CI:** add smoke tests + GitHub Actions.
- **Licensing:** add LICENSE (MIT/Apache-2.0?) and CONTRIBUTING.md.

## Next steps
1. Document `/chat` request/response schema with examples.
2. Add unit tests for `filters`, `triggers`, `memory`.
3. Create typed config + `.env.example`.
4. Wire minimal telemetry (timings, error counts) behind a flag.

— end —
