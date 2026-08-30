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

```bash
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
ollama pull codellama:7b
```

Start Ollama in one terminal, then in a second:
```bash
source ~/.bashrc
ai-with-memory
```

## Included commands

- `ai-with-memory` — chat with Avalhla
- `ai-progress` — see memory and learning stats
- `ai-remember` — review what it knows about you
- `ai-init` — initialize profile and settings
- `ai-learn` — add project files to the knowledge base

## Memory locations

- `~/.ai-memory/conversations`
- `~/.ai-memory/profiles`
- `~/.ai-memory/knowledge-base`
- `~/.ai-memory/preferences`

## Notes

Avalhla is designed as a terminal-first assistant. All memory stays local to the machine.
