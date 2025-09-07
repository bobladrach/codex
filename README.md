## LIMINA Codex
## Ari’el — Brain (submodule)
Path: `/ariel` • Repo: https://github.com/bobladrach/brain

### Quickstart
git submodule update --init --recursive
cd ariel
python -m venv .venv
..venv\Scripts\Activate.ps1
pip install -r requirements.txt
python ariel_server.py --host 127.0.0.1 --port 8000
