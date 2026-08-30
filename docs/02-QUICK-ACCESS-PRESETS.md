# ⚡ 02 — Quick Access Presets
**One-time install, then reusable forever. For Kevin Brooks / VVgbon916 · Bazzite Linux**

These are real bash functions — not just commands to retype. Install once, use by name from any terminal, forever (they live in `~/.bashrc`, which survives reboots automatically — nothing about storage needs "making persistent," only running processes like Ollama need restarting each session, covered at the bottom).

---

## 📌 Install (do this once)

Paste this whole block into your terminal one time:

```bash
cat >> ~/.bashrc << 'PRESETS_EOF'

# ============================================================
# QUICK ACCESS PRESETS — repo creation, linking, file drops
# ============================================================

# Create a brand new repo: folder + git init + push to GitHub
newrepo() {
  local name="$1"
  if [ -z "$name" ]; then
    echo "Usage: newrepo <repo-name>"
    return 1
  fi
  mkdir -p "$HOME/Documents/GitHub/$name"
  cd "$HOME/Documents/GitHub/$name" || return 1
  git init
  echo "# $name" > README.md
  git add README.md
  git commit -m "Initial commit"
  gh repo create --source=. --public
  echo "✅ Created and linked: $name"
}

# Link an EXISTING local folder to an EXISTING GitHub repo
linkrepo() {
  local url="$1"
  if [ -z "$url" ]; then
    echo "Usage: linkrepo <github-url>"
    return 1
  fi
  git remote add origin "$url" 2>/dev/null || git remote set-url origin "$url"
  git branch -M main
  git push -u origin main
  echo "✅ Linked to: $url"
}

# Move downloaded files (default: all) from ~/Downloads into <project>/docs
dropdocs() {
  local target="$1"
  local pattern="${2:-*}"
  if [ -z "$target" ]; then
    echo "Usage: dropdocs <target-project-path> [file-pattern]"
    echo "Example: dropdocs \"/home/VVgbon916/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1\""
    return 1
  fi
  mkdir -p "$target/docs"
  mv ~/Downloads/$pattern "$target/docs/" 2>/dev/null
  echo "✅ Moved matching files from ~/Downloads into $target/docs"
  ls -la "$target/docs"
}

# Quick commit + push from inside any repo folder
gitsave() {
  local msg="${1:-Update}"
  git add .
  git commit -m "$msg"
  git push
  echo "✅ Committed and pushed: $msg"
}

# One command: start Ollama + Claude Code together (run in a fresh terminal)
aicode() {
  OLLAMA_CONTEXT_LENGTH=65536 ollama serve &
  sleep 2
  claude
}

PRESETS_EOF
source ~/.bashrc
echo "Presets installed. Try: newrepo, linkrepo, dropdocs, gitsave, aicode"
```

That's a one-time paste. After it runs, these five commands exist forever, in every new terminal, automatically — because they now live in `~/.bashrc`, which is a normal file on disk.

---

## 🧰 The five commands, explained

### `newrepo <name>`
Creates a fresh folder under `~/Documents/GitHub/`, initializes git, makes a starter README, and creates + links the GitHub repo — all in one shot.
```bash
newrepo my-new-project
```

### `linkrepo <github-url>`
For a local folder that already has content but isn't connected to GitHub yet (exactly the situation Avalhla was in).
```bash
cd "/path/to/existing/project"
linkrepo https://github.com/VVgbon916/existing-repo.git
```

### `dropdocs <target-project-path> [pattern]`
Moves files out of `~/Downloads` straight into that project's `docs/` folder. Optional second argument filters by pattern (default: everything).
```bash
dropdocs "/home/VVgbon916/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1"
# or, just the markdown files:
dropdocs "/home/VVgbon916/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1" "*.md"
```

### `gitsave "message"`
Run from inside any repo folder — stages everything, commits, pushes, in one line.
```bash
cd "/path/to/project"
gitsave "Added new docs"
```

### `aicode`
Your daily Claude Code + Ollama startup, now one word instead of two terminals and three commands.
```bash
aicode
```
(Runs Ollama in the background of the same terminal, then launches Claude Code straight after.)

---

## 🔁 Your exact recurring workflow, now three commands

```bash
newrepo my-project
dropdocs "$HOME/Documents/GitHub/my-project"
gitsave "Add initial docs"
```

---

## 🧠 What actually needs restarting after a reboot (and what doesn't)

| Thing | Survives reboot? |
|---|---|
| Files, folders, git commits, repo history | ✅ Always — normal disk storage |
| `~/.bashrc` and everything in it (including these 5 presets) | ✅ Always |
| GitHub repo + everything pushed to it | ✅ Always — it's on GitHub's servers |
| `gh auth login` session | ✅ Usually persists — check with `gh auth status` if unsure |
| **`ollama serve` running process** | ❌ Stops on shutdown — restart with `aicode` or `ollama serve` |
| **`ava` / Claude Code active session** | ❌ Stops on shutdown — just run `ava` or `claude` again, memory/history is preserved even though the process restarted |

Nothing about your notes, code, or repos is ever at risk from a reboot — only the **running programs** need a fresh start, and now that's one word (`aicode`, or `ava`).
