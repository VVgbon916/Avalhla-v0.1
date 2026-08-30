Avalhla v0.1

Description:
Avalhla is a terminal-based personal AI assistant that remembers your profile,
stores recent conversations, and keeps a local knowledge base for future sessions.

Requirements:
- Linux or Unix-like terminal
- Ollama installed
- Local model: qwen3.5:9b

Quick setup:
mkdir -p ~/bin
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
ollama pull qwen3.5:9b

Then run:
cd "/home/VVgbon916/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1"
bash "Persistent AI Memory - Terminal AI That Learns & Knows You.sh"

Start the Ollama service in one terminal:
ollama serve

Then, in a second terminal, start Avalhla:
source ~/.bashrc
ai-with-memory

Reusable alias version:
echo 'alias ava="source ~/.bashrc >/dev/null 2>&1; ai-with-memory"' >> ~/.bashrc
echo 'alias ava-start="source ~/.bashrc >/dev/null 2>&1; ollama pull qwen3.5:9b >/dev/null 2>&1 || true; ai-with-memory"' >> ~/.bashrc
source ~/.bashrc

Then use:
ava
or:
ava-start

Reusable script version:
mkdir -p ~/bin
cat > ~/bin/ava <<'EOF'
#!/bin/bash
source ~/.bashrc
ollama pull qwen3.5:9b >/dev/null 2>&1 || true
ai-with-memory
EOF
chmod +x ~/bin/ava

Then use:
ava

Included commands:
ai-with-memory
ai-progress
ai-remember
ai-init
ai-learn

Memory locations:
~/.ai-memory/conversations
~/.ai-memory/profiles
~/.ai-memory/knowledge-base
~/.ai-memory/preferences

Troubleshooting:
If command not found:
source ~/.bashrc
hash -r

If Ctrl+C stops the session:
ava

If Ollama model is missing:
ollama pull qwen3.5:9b

Project folder:
/home/VVgbon916/Documents/VS Code v0.1 AI-Integration/Avalhla v0.1

Notes:
Avalhla is designed as a terminal-first assistant. It keeps memories local and personal to the machine.
