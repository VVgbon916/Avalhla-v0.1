# Avalhla v0.1

Avalhla is a terminal-based personal AI assistant that remembers your profile, stores recent conversations, and keeps a local knowledge base for future sessions.

## What this project does

- Creates a persistent memory folder in `~/.ai-memory`
- Stores your user profile and preferences
- Writes conversation history to daily JSONL logs
- Uses Ollama as the local AI backend
- Gives you shortcut commands like `ai-with-memory`, `ai-progress`, and `ai-remember`
- Lets you launch Avalhla with a reusable alias or script

## Requirements

- Linux or Unix-like terminal
- Ollama installed
- Local model available: `codellama:7b`

## Quick setup

Run this in your terminal:

```bash
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
ollama pull codellama:7b
```

Then run the setup script:

```bash
cd "/home/VVgbon916/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1"
bash "Persistent AI Memory - Terminal AI That Learns & Knows You.sh"
```

Start the local model service in one terminal:

```bash
ollama serve
```

Then, in a second terminal, start Avalhla:

```bash
source ~/.bashrc
ai-with-memory
```

## Reusable startup commands

### Alias version

```bash
echo 'alias ava="source ~/.bashrc >/dev/null 2>&1; ai-with-memory"' >> ~/.bashrc
echo 'alias ava-start="source ~/.bashrc >/dev/null 2>&1; ollama pull codellama:7b >/dev/null 2>&1 || true; ai-with-memory"' >> ~/.bashrc
source ~/.bashrc
```

Then use:

```bash
ava
```

or:

```bash
ava-start
```

### Script version

```bash
mkdir -p ~/bin
cat > ~/bin/ava <<'EOF'
#!/bin/bash
source ~/.bashrc
ollama pull codellama:7b >/dev/null 2>&1 || true
ai-with-memory
EOF
chmod +x ~/bin/ava
```

Then use:

```bash
ava
```

## Included commands

After setup, these commands are available:

- `ai-with-memory` — chat with Avalhla
- `ai-progress` — see memory and learning stats
- `ai-remember` — review what the AI knows about you
- `ai-init` — initialize profile and settings
- `ai-learn` — add project files to the knowledge base

## Memory locations

Your persistent data is stored here:

- `~/.ai-memory/conversations`
- `~/.ai-memory/profiles`
- `~/.ai-memory/knowledge-base`
- `~/.ai-memory/preferences`

## Troubleshooting

If `ai-with-memory` says command not found:

```bash
source ~/.bashrc
hash -r
```

If you accidentally press Ctrl+C while Avalhla is running, just launch it again:

```bash
ava
```

If Ollama is not installed or the model is missing:

```bash
ollama pull codellama:7b
```

## Project folder

```text
/home/VVgbon916/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1
```

## Notes

Avalhla is intentionally designed as a terminal-first assistant. It is built to feel personal, supportive, and efficient while keeping all memory local to the machine.
