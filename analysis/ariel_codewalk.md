# Ari’el Codewalk — v0

> Scope: quick pass to map entry points, HTTP surface, core modules, and data flow.  
> Repo: submodule `/ariel` (https://github.com/bobladrach/brain)

## 0. Snapshot
- Submodule commit: (fill from `git submodule status`)
- Tag/Release: v1.0-genesis-2025-08-16

## 1. Entry points
- `ariel_server.py` — CLI / app runner (host/port flags)
- `server/app.py` — Flask app wiring & extensions

## 2. HTTP surface
- `POST /chat` — conversational turn (filters → llm_adapter → memory)
- `POST /control` — control-plane mutations (mode/persona)
- `GET  /stream` — SSE/token stream

## 3. Core modules (server/core/)
- `emotion.py` — (fill)
- `filters.py` — (fill)
- `llm_adapter.py` — (fill)
- `memory.py` — (fill)
- `personas.py` — (fill)
- `state.py` — (fill)
- `triggers.py` — (fill)

## 4. Background loops (server/loops/)
- `breath.py` — (fill)
- `hrm.py`    — (fill)

## 5. Data flow (one request)
request → filters.pre → llm_adapter.call → memory.update → filters.post → response

## 6. Risks / TODOs (initial)
- Config: centralize env & secrets
- Observability: timings, error counts (feature-flagged)
- Tests: smoke tests for routes + unit tests for filters/triggers/memory
- CI: GitHub Actions (lint/test)
- License: choose (MIT/Apache-2.0)

## 7. Next steps
- Document `/chat` schema (req/resp examples)
- Add `.env.example` and typed settings
- Sequence diagram for `/chat`

— end —

## Repo tree (subset)

 - ariel\$null
 - ariel\.gitignore
 - ariel\ariel_server.py
 - ariel\data\memory.jsonl
 - ariel\README.md
 - ariel\readme.txt
 - ariel\requirements.txt
 - ariel\run.ps1
 - ariel\server\__init__.py
 - ariel\server\app.py
 - ariel\server\core\__init__.py
 - ariel\server\core\emotion.py
 - ariel\server\core\filters.py
 - ariel\server\core\llm_adapter.py
 - ariel\server\core\memory.py
 - ariel\server\core\personas.py
 - ariel\server\core\state.py
 - ariel\server\core\triggers.py
 - ariel\server\loops\__init__.py
 - ariel\server\loops\breath.py
 - ariel\server\loops\hrm.py
 - ariel\server\pages\__init__.py
 - ariel\server\pages\demo.py
 - ariel\server\pages\ui.py
 - ariel\server\routes\__init__.py
 - ariel\server\routes\chat.py
 - ariel\server\routes\control.py
 - ariel\server\routes\models.py
 - ariel\server\routes\stream.py
 - ariel\start_ariel.cmd
 - ariel\start_ariel.ps1

**Submodule status**:
 445f53c408125f2f0a780cd3b0dc089ffb771d5a ariel (v1.0-genesis-2025-08-16)
