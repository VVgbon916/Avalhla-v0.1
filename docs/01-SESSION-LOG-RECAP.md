# 📼 01 — Session Log Recap
**The real path we took — issues hit, and how each got resolved. For the archive.**

This isn't the clean tutorial (see `00-FROM-ZERO-SETUP-GUIDE.md` for that) — this is what actually happened, in order, so future-you (or Ava) can recognize these symptoms fast if they resurface.

---

## 1. Connecting Claude Code to Ollama — first attempt

**Goal:** point Claude Code at a local Ollama model instead of Anthropic's API, using `qwen3-coder:480b-cloud`.

**What happened:** set the env vars (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_MODEL`), launched `claude` — banner still showed `Opus 5 · API Usage Billing`.

**Root cause:** env vars weren't loaded in the shell session Claude Code was launched from.

**Fix:** confirmed with `echo $ANTHROPIC_MODEL` (came back blank), re-exported the three vars directly in the active shell before relaunching.

---

## 2. The `curl` 405 scare

**What happened:** ran `curl http://localhost:11434/v1/messages` to sanity-check the Ollama server — got `405 method not allowed` and briefly assumed something was broken.

**Actual status:** **not a bug.** 405 means the endpoint exists and is listening, it just doesn't like a plain `GET` request (the real API needs `POST` with a JSON body). A `404` would have meant genuinely broken.

**Lesson:** don't trust an HTTP status code you don't recognize — check what it actually means before troubleshooting further.

---

## 3. Cloud model retirement — `qwen3-coder:480b`

**What happened:** Claude Code connected fine, sent "hello," got back:
```
API Error: 410 qwen3-coder:480b was retired at 2026-07-15 00:00:00 -0700 PDT
```

**Root cause:** the cloud-hosted model tag had been discontinued on Ollama's servers — nothing wrong with the local setup.

**Fix:** switched to a local model instead of a cloud tag, since local models don't get remotely retired out from under you.

---

## 4. Picking the wrong local model — `glm-4.7-flash:latest`

**What happened:** picked `glm-4.7-flash:latest` (19GB) as "best choice, built for agentic tool-calling." Sent "hello" — it took **6 minutes** to respond.

**Root cause found via `nvidia-smi`:** RTX 3060 has 12GB VRAM total. A 19GB model cannot fit — nearly the entire model was running on CPU (`104MiB` on GPU vs. 19GB total model size).

**Fix:** checked `ollama list` for models that actually fit the 12GB budget, switched to `qwen3.5:9b` (6.6GB) — comfortably fits, much faster.

**Lesson:** always check model size against actual available VRAM before picking a model — bigger isn't better if it doesn't fit.

---

## 5. Context window stuck at 4096

**What happened:** even after setting `OLLAMA_CONTEXT_LENGTH=65536`, `ollama ps` kept showing `CONTEXT: 4096`.

**Root cause:** the env var only applies when the Ollama **server itself** starts — it was already running from a previous session, so the new value never took effect.

**Fix:**
```bash
pkill ollama
OLLAMA_CONTEXT_LENGTH=65536 ollama serve
```
Killing and restarting the server picked up the new value correctly.

---

## 6. Typing bash into Claude Code's chat by accident

**What happened:** typed `ollama ps` expecting a shell command — it went into Claude Code's `❯` chat prompt instead and produced garbled/irrelevant output.

**Root cause:** was still inside the Claude Code interactive session, which is a chat interface, not a shell — even though it looks similar in the terminal.

**Fix:** `/exit` (or Ctrl+C) to drop back to the actual shell prompt before running system commands.

---

## 7. Slow response even on a fitting model — GPU/CPU split

**What happened:** switched to `qwen3.5:9b` (6.6GB, should fit easily) — still took 36 seconds for "hello."

**Root cause:** `ollama ps` showed the model was still splitting across CPU/GPU, likely because `glm-4.7-flash` was still loaded in memory at the same time, competing for VRAM.

**Fix:** `ollama stop <other-model>` to unload anything not in use, keeping only the active model in memory.

---

## 8. Building the cheat sheets — Runset DEBUG=true typo

**What happened:** a compiled command sequence included `Runset DEBUG=true` before `claude` — not a real command.

**Root cause:** likely a mixed-up note, not an actual Claude Code flag.

**Fix:** the real equivalent is `claude --debug` or `claude --debug-file <path>` — corrected in the final cheat sheet.

---

## 9. `gh repo view` — "not a git repository"

**What happened:** ran `gh repo view` from `/var/home/VVgbon916` (home directory) — got:
```
fatal: not a git repository (or any parent up to mount point /var)
```

**Root cause:** `gh repo view` (and most `gh`/`git` commands) only work from inside an actual git repository folder — home directory itself isn't one.

**Fix:** `cd` into the actual project folder before running `gh` commands.

---

## 10. `gh repo create` — "Name already exists on this account"

**What happened:** ran `git init && git add . && git commit && gh repo create --source=. --public` inside the Avalhla folder — got a GraphQL error saying the repo name already existed.

**Root cause:** a repo with that name had already been created on GitHub in an earlier session — this folder just wasn't linked to it yet locally.

**Fix:**
```bash
gh repo view VVgbon916/Avalhla-v0.1     # confirmed it existed, empty
git remote add origin https://github.com/VVgbon916/Avalhla-v0.1.git
git branch -M main
git push -u origin main
```

---

## 11. `sed`/`xargs` breaking on a path with spaces

**What happened:** ran a batch find-and-replace across files:
```bash
grep -rl "codellama:7b" "/path/with spaces/Avalhla v0.1" | xargs sed -i 's/.../.../g'
```
Got a wall of `sed: can't read /home/...: No such file or directory` errors — `xargs` had split the path into fragments on every space.

**Root cause:** `xargs` splits input on whitespace by default; a path containing literal spaces (`VS Code v0.1 AI-Integration`) got torn apart.

**Fix:** use null-delimited output/input so spaces are treated as part of the filename, not a separator:
```bash
grep -rlZ "codellama:7b" "/path/with spaces/Avalhla v0.1" | xargs -0 sed -i 's/codellama:7b/qwen3.5:9b/g'
```
`-Z` on `grep` and `-0` on `xargs` fixed it cleanly across all 6 affected files in one pass.

---

## 12. Accidentally pasting a script snippet as a live command

**What happened:** while discussing script internals, a quoted `if` line from inside the `.sh` file got pasted directly into the terminal — left the shell hanging at a `>` continuation prompt.

**Root cause:** the line was an incomplete `if` block (missing its `then`/`fi`), so bash was waiting for the rest of it.

**Fix:** `Ctrl+C` to cancel the incomplete input and return to a normal prompt.

---

## 📊 Final state after this session

| Component | Status |
|---|---|
| Ollama | ✅ Running, `qwen3.5:9b` loaded, 65536 context |
| Claude Code | ✅ Connected to Ollama, confirmed via banner |
| GitHub CLI | ✅ Authenticated (v2.98), repo linked and pushed |
| Avalhla | ✅ Model switched to `qwen3.5:9b` across all files, launches cleanly |
| Repo | `github.com/VVgbon916/Avalhla-v0.1` — README + code pushed |

---

*Paired with `00-FROM-ZERO-SETUP-GUIDE.md` — that one's the clean instructions; this one's the "here's what actually goes wrong" reference.*
