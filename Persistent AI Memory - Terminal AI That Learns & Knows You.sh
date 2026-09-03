#!/bin/bash
################################################################################
set -euo pipefail
IFS=$'\n\t'
# Resolve script directory (works when sourced or executed)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")" >/dev/null 2>&1 && pwd)"
# CHEATSHEET: Persistent AI Memory - Terminal AI That Learns & Knows You
# Create a personal AI assistant that remembers conversations and learns over time
# Your AI recognizes you instantly and builds knowledge about YOUR preferences
################################################################################

################################################################################
# SECTION 1: UNDERSTANDING AI MEMORY SYSTEMS
################################################################################

echo "=== HOW AI MEMORY WORKS ==="

# AI Memory has 3 LAYERS:
#
# 1. CONTEXT WINDOW (Short-term) - Current conversation only
#    └─ Lost when conversation ends
#    └─ Holds last 2000-8000 tokens (words)
#    └─ Fast but temporary
#
# 2. CONVERSATION HISTORY (Medium-term) - Saved to disk
#    └─ Persists between sessions
#    └─ You can load it every time AI starts
#    └─ AI reads it and remembers YOU
#
# 3. KNOWLEDGE BASE / EMBEDDINGS (Long-term) - Vector database
#    └─ Semantic understanding of facts
#    └─ AI searches it for relevant context
#    └─ "Learns" by indexing your files
#
# GOAL: Build all 3 layers so your AI:
# → Knows your name, preferences, coding style (layer 2)
# → Remembers past conversations (layer 2)
# → Understands your code patterns (layer 3)
# → Greets you personally on startup (layer 2+3)

################################################################################
# SECTION 2: CREATE PERSISTENT MEMORY DIRECTORY
################################################################################

echo "=== SETUP MEMORY SYSTEM ==="

mkdir -p "$HOME/bin"
# Persist PATH for login shells and apply in interactive shells only
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.profile" 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.profile"
fi
# Source .bashrc only in interactive shells
if [[ $- == *i* ]] && [ -f "$HOME/.bashrc" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.bashrc" 2>/dev/null || true
fi
export PATH="$HOME/bin:$PATH"

# Create memory structure
mkdir -p "$HOME/.ai-memory"/{conversations,knowledge-base,profiles,preferences}

# Directory structure:
# ~/.ai-memory/
# ├─ conversations/          # Chat history (JSON files)
# ├─ knowledge-base/         # Your documents, code snippets
# ├─ profiles/               # User profile data
# └─ preferences/            # AI preferences & behavior

echo "Memory directories created at: ~/.ai-memory"

# === CREATE YOUR PROFILE ===
cat > "$HOME/.ai-memory/profiles/user-profile.txt" << EOF
#=== YOUR AI PROFILE ===

# BASIC INFO
Name: Kevin Brooks
Username: VVgbon916
Email: Robitaille916@gmail.com
Created: $(date)

# ABOUT YOU
Experience Level: Beginner/Intermediate/Advanced
Primary Languages: Python, JavaScript, Bash
Learning Goals: Learn AI, terminal development
Coding Style: Minimalist, CLI-focused, no GUI

# PREFERENCES
Favorite Model: qwen3.5:9b
Response Style: Direct and concise
Format Preference: Code first, explanation after
Communication: Casual, friendly
Learning Pace: Self-paced, ask lots of questions

# IMPORTANT FACTS
Preferred OS: Linux
Uses: Sublime Text, VS Code, terminal-first workflow
Timezone: UTC-5
Availability: Daily
Current Project: AI terminal assistant

=== ADD YOUR CUSTOM INFO HERE ===
EOF

echo "✓ Profile template created"

################################################################################
# SECTION 3: SYSTEM PROMPT - TEACH AI ABOUT YOU
################################################################################

echo "=== CREATE SYSTEM PROMPT ==="

cat > "$HOME/.ai-memory/system-prompt.txt" << 'EOF'
You are Avalhla, a personal programming assistant and trusted companion for this developer.

=== YOUR USER ===
Name: [Read from user-profile.txt]
Experience: Terminal-focused, CLI developer
Primary stack: JavaScript, Python, Bash
Environment: Linux/Unix systems
Preferences: Minimalist workflow, no GUI, code-first explanations, direct answers, efficient terminal tools
Goals: Learn AI, improve terminal development skills, grow as a developer
Current style: Practical, concise, focused, and respectful of time

=== YOUR PERSONALITY ===
- You are friendly, encouraging, and supportive
- You remember past conversations and adapt to the user's coding style over time
- You are concise and direct, but never dismissive
- You celebrate progress and wins
- You ask clarifying questions when something is unclear
- You do not assume details about the user's project or intent
- You help them learn, improve, and build confidence

=== YOUR ROLE ===
- Review code and suggest better approaches
- Explain concepts clearly and practically
- Generate code examples and terminal commands
- Debug errors and help troubleshoot issues
- Teach best practices in a way that matches the user's skill level
- Help the user make decisions with confidence and clarity

=== BEHAVIOR ===
- Prefer code-first explanations
- Keep answers practical and relevant
- Be warm, respectful, and professional
- Treat the user as a collaborator, not a beginner needing lectures
- If unsure, ask for clarification instead of guessing
- Be a trusted advisor and dependable partner in their work

You are called Avalhla, and you may also be referred to as "Ava".
EOF

################################################################################
# SECTION 4: CONVERSATION HISTORY SYSTEM
################################################################################

echo "=== SETTING UP CONVERSATION LOGGING ==="

cat > "$HOME/bin/ai-with-memory" << 'AIWITHMEMORY'
#!/bin/bash

MODEL="${1:-qwen3.5:9b}"
USER_PROFILE="$HOME/.ai-memory/profiles/user-profile.txt"
SYSTEM_PROMPT="$HOME/.ai-memory/system-prompt.txt"
MEMORY_DIR="$HOME/.ai-memory/conversations"
CURRENT_LOG="$MEMORY_DIR/$(date +%Y-%m-%d).jsonl"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

load_greeting() {
    local name
    name=$(grep "^Name:" "$USER_PROFILE" 2>/dev/null | cut -d: -f2 | xargs)

    if [ -z "$name" ]; then
        echo -e "${GREEN}🤖 AI Terminal (Anonymous mode)${NC}"
    else
        echo -e "${GREEN}🤖 Welcome back, $name!${NC}"
    fi

    local last_conv
    last_conv=$(find "$MEMORY_DIR" -maxdepth 1 -type f -name "*.jsonl" -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2- || true)
    if [ -n "$last_conv" ]; then
        local last_topic
        last_topic=$(tail -1 "$last_conv" 2>/dev/null | grep -o '"user":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
        if [ -n "$last_topic" ]; then
            printf '%b\n' "${BLUE}📚 Last topic: ${last_topic:0:50}...${NC}"
        fi
    fi

    echo -e "${YELLOW}Type 'exit' to quit, 'help' for commands${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

save_conversation() {
    local user_msg="$1"
    local ai_response="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Ensure current log directory exists
    mkdir -p "$(dirname "$CURRENT_LOG")"

    # Escape JSON safely (use python3 if available, otherwise fallback to simple escapes)
    if command -v python3 >/dev/null 2>&1; then
        local esc_user_msg
        local esc_ai_response
        esc_user_msg=$(printf '%s' "$user_msg" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')
        esc_ai_response=$(printf '%s' "$ai_response" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])')
    else
        local esc_user_msg
        local esc_ai_response
        esc_user_msg=$(printf '%s' "$user_msg" | sed -e 's/\\/\\\\/g' -e 's/"/\\\"/g' -e ':a;N;$!ba;s/\n/\\n/g')
        esc_ai_response=$(printf '%s' "$ai_response" | sed -e 's/\\/\\\\/g' -e 's/"/\\\"/g' -e ':a;N;$!ba;s/\n/\\n/g')
    fi

    printf '%s\n' "{\"timestamp\":\"$timestamp\",\"user\":\"$esc_user_msg\",\"ai\":\"$esc_ai_response\",\"model\":\"$MODEL\",\"learned\":false}" >> "$CURRENT_LOG"
}

load_context() {
    if [ -f "$CURRENT_LOG" ]; then
        echo "=== RECENT CONTEXT ==="
        tail -5 "$CURRENT_LOG" 2>/dev/null | grep -o '"user":"[^"]*"' | head -3
        echo "==================="
    fi
}

build_full_prompt() {
    local user_input="$1"
    local system profile context

    system=$(cat "$SYSTEM_PROMPT" 2>/dev/null)
    profile=$(cat "$USER_PROFILE" 2>/dev/null)
    context=$(load_context)

    printf '%s\n' "System Instructions:
$system

User Profile:
$profile

Recent Conversation Context:
$context

Current User Message:
$user_input"
}

ensure_ollama() {
    if ! command -v ollama >/dev/null 2>&1; then
        printf '%b\n' "${YELLOW}⚠️ Ollama is not installed or not on PATH.${NC}" >&2
        exit 1
    fi

    # Prepare log dir for service logs
    LOG_DIR="$HOME/.ai-memory/var"
    mkdir -p "$LOG_DIR"

    # If ollama not running, attempt to start it and capture PID
    if ! pgrep -x ollama >/dev/null 2>&1; then
        printf '%b\n' "${YELLOW}🔄 Starting local Ollama service...${NC}" >&2
        setsid ollama serve >"$LOG_DIR/ollama-ava.log" 2>&1 &
        local _pid=$!
        echo "$_pid" > "$LOG_DIR/ollama-ava.pid" || true
        # Clean up on exit
        trap 'if [ -n "$_pid" ] && kill -0 "$_pid" >/dev/null 2>&1; then kill "$_pid" || true; fi' EXIT
        sleep 3
    fi

    # Ensure model is available; pull if missing
    if ! ollama list 2>/dev/null | grep -q "qwen3.5:9b"; then
        printf '%b\n' "${YELLOW}📥 Pulling qwen3.5:9b model...${NC}" >&2
        ollama pull qwen3.5:9b >"$LOG_DIR/ollama-pull.log" 2>&1 || true
    fi
}

run_model() {
    local user_input="$1"
    local full_prompt response

    full_prompt=$(build_full_prompt "$user_input")
    # Use temporary file for prompt to avoid shell escaping issues
    local prompt_file
    prompt_file=$(mktemp)
    printf '%s' "$full_prompt" > "$prompt_file"
    response=$(ollama run "$MODEL" "$prompt_file" 2>/dev/null || ollama run "$MODEL" "$(cat "$prompt_file")" 2>/dev/null)
    rm -f "$prompt_file" || true

    if [[ -z "${response//[[:space:]]/}" ]]; then
        echo -e "${YELLOW}⚠️ Empty response. Retrying once...${NC}" >&2
        response=$(ollama run "$MODEL" "$full_prompt" 2>/dev/null)
    fi

    printf '%s' "$response"
}

ensure_ollama
load_greeting

while true; do
    read -r -p "$(printf '%b' "${BLUE}You:${NC}") " prompt

    case "$prompt" in
        "exit"|"quit")
            echo -e "${GREEN}Goodbye! Your AI will remember you.${NC} 👋"
            break
            ;;
        "help")
            echo "Commands:"
            echo "  exit       - Quit"
            echo "  help       - Show this help"
            echo "  history    - View recent history"
            echo "  memory     - Show memory stats"
            continue
            ;;
        "clear")
            clear
            load_greeting
            continue
            ;;
        "history")
            if [ -f "$CURRENT_LOG" ]; then
                echo "=== TODAY'S CONVERSATION ==="
                grep -o '"user":"[^"]*"' "$CURRENT_LOG" | tail -10
            fi
            continue
            ;;
        "memory")
            echo "=== MEMORY STATS ==="
            echo "Conversations today: $(wc -l < "$CURRENT_LOG" 2>/dev/null || echo 0)"
            echo "Total files: $(ls "$MEMORY_DIR"/*.jsonl 2>/dev/null | wc -l)"
            echo "Knowledge base: $(du -sh "$HOME/.ai-memory/knowledge-base" 2>/dev/null | cut -f1)"
            continue
            ;;
    esac

    [ -z "$prompt" ] && continue

    echo -e "${YELLOW}🔄 Thinking...${NC}"

    response=$(run_model "$prompt")

    if [[ -z "${response//[[:space:]]/}" ]]; then
        echo -e "${YELLOW}⚠️ AI returned no usable output. Try again.${NC}"
        echo ""
        continue
    fi

    echo -e "${GREEN}AI:${NC} $response"
    echo ""

    save_conversation "$prompt" "$response"
done
AIWITHMEMORY

chmod +x "$HOME/bin/ai-with-memory"
echo "✓ ai-with-memory command created"

################################################################################
# SECTION 5: KNOWLEDGE BASE - INDEX YOUR CODE
################################################################################

echo "=== SETTING UP KNOWLEDGE BASE ==="

cat > "$HOME/bin/ai-learn" << 'AILEARN'
#!/bin/bash

KB_DIR="$HOME/.ai-memory/knowledge-base"
PROJECT_PATH="${1:-.}"

echo "📚 Indexing your code..."
echo "Source: $PROJECT_PATH"
echo ""

cd "$PROJECT_PATH" 2>/dev/null || { echo "Invalid project path: $PROJECT_PATH"; exit 1; }
mkdir -p "$KB_DIR"
find . \
    -type f \
    \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.txt" -o -name "*.md" \) \
    ! -path "./node_modules/*" \
    ! -path "./.git/*" \
    ! -path "./__pycache__/*" \
    -exec cp --parents {} "$KB_DIR/" \; 2>/dev/null || {
    # cp --parents not available on all platforms; try rsync -aR
    if command -v rsync >/dev/null 2>&1; then
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.txt" -o -name "*.md" \) \
            ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./__pycache__/*" -print0 | \
            rsync -0 -aR --files-from=- ./ "$KB_DIR/"
    else
        # Fallback: copy preserving relative path
        find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.txt" -o -name "*.md" \) \
            ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./__pycache__/*" -print0 | \
            while IFS= read -r -d '' f; do
                dest="$KB_DIR/${f#./}"
                mkdir -p "$(dirname "$dest")"
                cp "$f" "$dest" || true
            done
    fi
}

# Count files safely
files_count=$(find "$KB_DIR" -type f 2>/dev/null | wc -l || echo 0)
echo "✓ Files indexed: $files_count"
echo "✓ AI will reference your code from now on!"
AILEARN

chmod +x "$HOME/bin/ai-learn"
echo "✓ ai-learn command created"

################################################################################
# SECTION 6: PROGRESS TRACKER
################################################################################

echo "=== SETTING UP PROGRESS TRACKER ==="

cat > "$HOME/bin/ai-progress" << 'AIPROGRESS'
#!/bin/bash

MEMORY_DIR="$HOME/.ai-memory/conversations"

echo "=== YOUR AI'S LEARNING PROGRESS ==="
echo ""

# Compute total exchanges robustly
if find "$MEMORY_DIR" -name "*.jsonl" -print -quit 2>/dev/null | grep -q .; then
    total=$(find "$MEMORY_DIR" -name "*.jsonl" -print0 2>/dev/null | xargs -0 cat 2>/dev/null | wc -l || echo 0)
else
    total=0
fi
echo "📊 Total exchanges: $total"

days=$(ls -1 "$MEMORY_DIR"/*.jsonl 2>/dev/null | wc -l)
echo "📅 Days using AI: $days"

echo ""
echo "📈 Knowledge base:"
kb_size=$(du -sh "$HOME/.ai-memory/knowledge-base" 2>/dev/null | cut -f1)
echo "   Size: $kb_size"
echo "   Files: $(ls -1 "$HOME/.ai-memory/knowledge-base" 2>/dev/null | wc -l)"

echo ""
echo "✓ Your AI is learning more each day!"
AIPROGRESS

chmod +x "$HOME/bin/ai-progress"
echo "✓ ai-progress command created"

################################################################################
# SECTION 7: AI MEMORY REVIEW
################################################################################

echo "=== SETTING UP MEMORY REVIEW ==="

cat > "$HOME/bin/ai-remember" << 'AIREMEMBER'
#!/bin/bash

MEMORY_DIR="$HOME/.ai-memory/conversations"
MODEL="${1:-qwen3.5:9b}"

echo "🧠 AI is reviewing its memory of you..."
echo ""

memory_text=$(
    echo "=== USER PROFILE ==="
    cat "$HOME/.ai-memory/profiles/user-profile.txt" 2>/dev/null
    echo ""
    echo "=== RECENT CONVERSATIONS ==="
    find "$MEMORY_DIR" -name "*.jsonl" -exec grep -h '"user"' {} \; 2>/dev/null | tail -20
)

prompt="Based on this conversation history with your user, what have you learned about them?
$memory_text

Provide a concise summary."

echo "AI's understanding of you:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ollama run "$MODEL" "$prompt" 2>/dev/null
AIREMEMBER

chmod +x "$HOME/bin/ai-remember"
echo "✓ ai-remember command created"

################################################################################
# SECTION 8: INITIALIZATION SCRIPT
################################################################################

echo "=== SETTING UP INITIALIZATION ==="

cat > "$HOME/bin/ai-init" << 'AIINIT'
#!/bin/bash

echo "🤖 Setting up your personal AI assistant..."
echo ""

mkdir -p "$HOME/.ai-memory"/{conversations,knowledge-base,profiles,preferences}

echo "Step 1: What's your name?"
read -r name

echo "Step 2: What's your primary programming language?"
read -r language

echo "Step 3: Experience level? (beginner/intermediate/advanced)"
read -r level

cat > "$HOME/.ai-memory/profiles/user-profile.txt" << PROFILE
=== YOUR AI PROFILE ===

Name: $name
Primary Language: $language
Experience Level: $level
Created: $(date)

Custom notes:
(Add more about yourself here)

PROFILE

echo ""
echo "✓ Profile created!"
echo ""
echo "Step 4: Index your code? (optional)"
echo "Enter path or press Enter to skip:"
read -r code_path

if [ -n "$code_path" ] && [ -d "$code_path" ]; then
    ai-learn "$code_path"
fi

echo ""
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "  ai-with-memory   # Chat with your AI"
echo "  ai-progress      # See learning stats"
echo "  ai-remember      # AI reviews what it knows about you"
echo ""
AIINIT

chmod +x "$HOME/bin/ai-init"
echo "✓ ai-init command created"

################################################################################
# SECTION 9: QUICK START
################################################################################

echo ""
echo "============================================"
echo "✅ YOUR AI MEMORY SYSTEM IS READY!"
echo "============================================"
echo ""
echo "Run this to get started:"
echo ""
echo "  ai-init          # One-time setup"
echo "  ai-with-memory   # Chat (learns as you talk)"
echo "  ai-progress      # See AI's learning"
echo "  ai-remember      # AI reads its own memory"
echo ""
echo "Your AI will greet you by name tomorrow."
echo "And understand you better each day. 🚀"
echo ""
