# Ari'el Self-Test — health, demo, emotion-or-chat check (Codex-compatible)
# Works with older Brain-style /insight/emotion and newer Codex /chat flow.

import argparse
import json
import sys
import time
from typing import Dict, Iterable, Tuple

import requests as r

def ok(resp: r.Response, label: str):
    print(f"{label}: {resp.status_code}")
    if resp.status_code != 200:
        try:
            print(resp.text[:200])
        except Exception:
            pass

def try_get(url: str, label: str, timeout: float = 5.0) -> Tuple[bool, r.Response]:
    try:
        resp = r.get(url, timeout=timeout)
        ok(resp, label)
        return resp.status_code == 200, resp
    except Exception as e:
        print(f"{label}: ERROR {e}")
        return False, None  # type: ignore

def try_post(base: str, paths: Iterable[str], payloads: Iterable[Dict], timeout: float = 10.0) -> Tuple[str, r.Response]:
    """
    Try each (path, payload) combo. Return first 200 OK.
    """
    for path in paths:
        for pl in payloads:
            url = f"{base}{path}"
            try:
                resp = r.post(url, json=pl, timeout=timeout)
                print(f"Trying {path} with {list(pl.keys())[0]} -> {resp.status_code}")
                if resp.status_code == 200:
                    return path, resp
            except Exception as e:
                print(f"Trying {path}: ERROR {e}")
    return "", None  # type: ignore

def pretty_json(snippet: str) -> str:
    try:
        obj = json.loads(snippet)
        return json.dumps(obj, indent=2)[:800]
    except Exception:
        return snippet[:800]

def extract_top_emotions(resp_json: Dict) -> str:
    """
    Support both patterns:
    - classic emotion API: {top_emotions: [{label, score}, ...]}
    - codex chat:         {top_emotions: [...]} or {memory_token: {top_emotions: [...]} }
    """
    # direct at root
    te = resp_json.get("top_emotions")
    if isinstance(te, list) and te:
        return ", ".join(f"{e.get('label','?')} {float(e.get('score',0)):.2f}" for e in te[:5])
    # nested under memory_token
    mt = resp_json.get("memory_token", {})
    te2 = mt.get("top_emotions")
    if isinstance(te2, list) and te2:
        return ", ".join(f"{e.get('label','?')} {float(e.get('score',0)):.2f}" for e in te2[:5])
    return "(no top_emotions field found)"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8000)
    ap.add_argument("--timeout", type=float, default=10.0)
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()

    base = f"http://{args.host}:{args.port}"

    print("=== HEALTH ===")
    ok1, _ = try_get(f"{base}/health", "/health", timeout=args.timeout)

    print("=== DEMO ===")
    ok2, _ = try_get(f"{base}/demo", "/demo", timeout=args.timeout)

    print("=== EMOTION / CHAT ===")
    payloads = [
        {"text": "Please summarize my mood: calm but a little worried about deadlines."},
        {"message": "Please summarize my mood: calm but a little worried about deadlines."},
    ]
    # Try legacy emotion endpoints first, then Codex chat
    paths = [
        "/insight/emotion",
        "/emotion",
        "/api/emotion",
        "/insight/affect",
        "/insight/affect/analyze",
        "/chat",
    ]
    path, resp = try_post(base, paths, payloads, timeout=args.timeout)
    if resp is None:
        print("No emotion/chat endpoint matched. This build may not expose analysis; use /chat for interaction.")
        sys.exit(1)

    # Print brief body + emotions summary
    body_text = resp.text or ""
    if args.verbose:
        print("Body (pretty):")
        print(pretty_json(body_text))
    else:
        print("Body (first 200 chars):", body_text[:200])

    # Attempt to parse + summarize emotions
    try:
        obj = resp.json()
        summary = extract_top_emotions(obj)
        print("Top emotions:", summary)
    except Exception:
        print("Top emotions: (response not JSON or missing fields)")

    # Simple exit code summary
    if ok1 and ok2 and resp.status_code == 200:
        sys.exit(0)
    sys.exit(2)

if __name__ == "__main__":
    main()
