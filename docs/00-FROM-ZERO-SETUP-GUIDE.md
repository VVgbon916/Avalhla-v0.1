# 📖 00 — From Zero: Full Setup Manual
**Bazzite Linux · RTX 3060 12GB · Ollama + Claude Code + GitHub CLI + Avalhla**

This assumes a fresh Bazzite install with nothing configured yet. Follow top to bottom.

---

## 📐 How to read command syntax (quick primer)

Before the steps — you'll see notation like this throughout tech docs, so here's what it means:

| Symbol | Meaning | Example |
|---|---|---|
| `<angle brackets>` | **Required** — you must supply this | `git clone <url>` → you must give a real URL |
| `[square brackets]` | **Optional** — can be left out | `ollama pull <model>[:tag]` → tag is optional |
| `[a\|b\|c]` | Optional, **pick one** | `--mode [auto\|manual]` |
| `{a\|b\|c}` | Required, **pick one** | `{start\|stop\|restart}` |
| `...` or `[item]...` | Can repeat | `cp <src>... <dest>` |
| `--flag=<value>` | A named option taking a value | `--model=qwen3.5:9b` |

**Worked example — locale string syntax**, which follows the same nesting logic:
```
<language>[_<territory>[.<character-set>[,<version>]]]
```
Reading it from the inside out:
- `<language>` — required (e.g. `en`, `fr`)
- `[_<territory>` — optional, but if present, needs a territory code (e.g. `_US`, `_CA`)
- `[.<character-set>` — optional, but only valid if territory was given (e.g. `.UTF-8`)
- `[,<version>]` — optional, only valid if character-set was given

So `en_US.UTF-8` is valid, `en.UTF-8` is not (skipped a required nesting level), and `en` alone is valid (everything optional was dropped). Every command reference in this manual uses the same bracket logic.

---

## PART 1 — Confirm your GPU driver

Bazzite ships with NVIDIA drivers pre-integrated on Nvidia builds of the OS — you likely don't need to install anything manually. Just confirm it's active:

```bash
nvidia-smi
```

**Expected output:** a table showing your GPU name, driver version, and VRAM (you should see `NVIDIA GeForce RTX 3060` and `12288MiB` total memory). If this command isn't found or errors, you likely installed the non-Nvidia Bazzite variant — check `bazzite.gg` docs for switching images, since that's a base-image change, not a driver patch.

---

## PART 2 — Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama --version
```
Confirm version is 0.15+ (needed for native Claude Code compatibility). If older:
```bash
curl -fsSL https://ollama.com/install.sh | sh   # re-run to update
```

## PART 3 — Pull your model

```bash
ollama pull qwen3.5:9b
ollama list
```
`qwen3.5:9b` (6.6GB) is the recommended daily driver for a 12GB GPU — fits fully in VRAM without CPU spillover. Avoid anything over ~10GB (e.g. models in the 18–20GB range will run painfully slow, mostly on CPU).

## PART 4 — Start Ollama with a real context window

Default context is only 4096 tokens — too small for agentic coding work. Always start it like this:
```bash
OLLAMA_CONTEXT_LENGTH=65536 ollama serve
```
Leave this running in its own terminal, always.

---

## PART 5 — Install Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
```

## PART 6 — Connect Claude Code to Ollama

One-time permanent config:
```bash
echo 'export ANTHROPIC_BASE_URL="http://localhost:11434"' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="ollama"' >> ~/.bashrc
echo 'export ANTHROPIC_MODEL="qwen3.5:9b"' >> ~/.bashrc
source ~/.bashrc
echo $ANTHROPIC_MODEL          # should print: qwen3.5:9b
```

## PART 7 — Daily launch routine (every time, from here on)

```bash
# Terminal 1 — start Ollama, leave running
OLLAMA_CONTEXT_LENGTH=65536 ollama serve
```
```bash
# Terminal 2 — launch Claude Code
claude
```
Banner should show `qwen3.5:9b` — not `Opus 5`. If it shows Opus 5, your env vars from Part 6 didn't load; re-check `echo $ANTHROPIC_MODEL`.

---

## PART 8 — Install & authenticate GitHub CLI

```bash
sudo apt install gh          # or your distro's equivalent package manager command
gh auth login
```
Follow prompts: `GitHub.com` → `HTTPS` → authenticate via browser or a personal access token (needs `repo`, `read:org`, `workflow` scopes if using a token).

Confirm:
```bash
gh auth status
```

---

## PART 9 — Set up Avalhla (local memory-based assistant)

This is a **separate** assistant from Claude Code — its own Ollama-backed chat with persistent local memory.

```bash
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Run the setup script from wherever you keep the project (adjust path to your actual location):
```bash
cd "/home/<you>/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1"
bash "Persistent AI Memory - Terminal AI That Learns & Knows You.sh"
```

Install the reusable launcher alias:
```bash
echo 'alias ava="source ~/.bashrc >/dev/null 2>&1; ai-with-memory"' >> ~/.bashrc
echo 'alias ava-start="source ~/.bashrc >/dev/null 2>&1; ollama pull qwen3.5:9b >/dev/null 2>&1 || true; ai-with-memory"' >> ~/.bashrc
source ~/.bashrc
```

Launch it:
```bash
ava
```

**Memory storage locations** (all local to your machine):
```
~/.ai-memory/conversations
~/.ai-memory/profiles
~/.ai-memory/knowledge-base
~/.ai-memory/preferences
```

---

## PART 10 — Link a project folder to GitHub

If a project folder isn't a git repo yet:
```bash
cd /path/to/project
git init
git add .
git commit -m "Initial commit"
gh repo create --source=. --public
```

If the GitHub repo already exists but isn't linked locally:
```bash
git remote add origin https://github.com/<you>/<repo-name>.git
git branch -M main
git push -u origin main
```

---

## ✅ Full "from zero" verification checklist

```bash
nvidia-smi                # GPU detected, 12288MiB shown
ollama --version           # 0.15+
ollama list                 # qwen3.5:9b present
gh auth status              # logged in
echo $ANTHROPIC_MODEL       # qwen3.5:9b
claude                       # banner shows qwen3.5:9b, not Opus 5
ava                          # Avalhla launches, greets you by name
```

If every line above checks out, the entire stack is built correctly from a bare Bazzite install.

---

*See `01-SESSION-LOG-RECAP.md` in this same folder for the real troubleshooting history — every issue actually hit while building this, and exactly how each was resolved.*
