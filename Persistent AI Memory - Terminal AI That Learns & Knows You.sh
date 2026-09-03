#!/bin/bash
################################################################################
set -euo pipefail
IFS=$'\n\t'
# Strict mode enabled (set -euo pipefail)"
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
# shellcheck disable=SC2016
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.profile" 2>/dev/null; then
    # shellcheck disable=SC2016
    printf '%s\n' 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.profile"
fi
# Source .bashrc only in interactive shells
if [[ $- == *i* ]] && [ -f "$HOME/.bashrc" ]; then
    # shellcheck disable=SC1090,SC1091
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
- Research topics online when asked (use provided web data)
- Reference the user's files, bash history, and system information
- Help with the user's Avalhla-v0.1 project (GitHub: VVgbon916/Avalhla-v0.1)

=== CAPABILITIES ===
- Access to user's knowledge base: code files, documents, and projects
- Access to Avalhla-v0.1 project (both local folders and GitHub repository)
- Access to bash history and CLI commands
- System information: OS, installed tools, environment
- Can research online topics (web data will be provided)
- Can suggest terminal-based solutions
- Can reference GitHub repo: https://github.com/VVgbon916/Avalhla-v0.1
- Can help with GitHub issues, PRs, and code reviews
- Can access Avalhla project structure and documentation

=== BEHAVIOR ===
- Prefer code-first explanations
- Keep answers practical and relevant
- Be warm, respectful, and professional
- Treat the user as a collaborator, not a beginner needing lectures
- If unsure, ask for clarification instead of guessing
- Be a trusted advisor and dependable partner in their work
- When asked to research, use provided web information or suggest curl/wget commands

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
RED='\033[0;31m'
NC='\033[0m'

# Function to fetch web content (research)
fetch_web_content() {
    local query="$1"
    local max_attempts=2
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if command -v curl >/dev/null 2>&1; then
            curl -s --max-time 5 "https://duckduckgo.com/?q=$(printf '%s' "$query" | sed 's/ /+/g')" 2>/dev/null | grep -o -E '<a[^>]*>.*?</a>' | head -5 && return 0
        elif command -v wget >/dev/null 2>&1; then
            wget -q -O - --timeout=5 "https://duckduckgo.com/?q=$(printf '%s' "$query" | sed 's/ /+/g')" 2>/dev/null | grep -o -E '<a[^>]*>.*?</a>' | head -5 && return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    return 1
}

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

    echo -e "${YELLOW}Type 'exit' to quit, 'help' for commands, or 'research <topic>' to search online${NC}"
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
    local system profile context bash_history system_info kb_snippets

    system=$(cat "$SYSTEM_PROMPT" 2>/dev/null)
    profile=$(cat "$USER_PROFILE" 2>/dev/null)
    context=$(load_context)
    
    # Load recent bash history
    bash_history=""
    if [ -f "$HOME/.bash_history" ]; then
        bash_history=$(tail -20 "$HOME/.bash_history" 2>/dev/null | sed 's/^/  /')
    fi
    
    # Load system info
    system_info=""
    if [ -f "$HOME/.ai-memory/knowledge-base/system-info.txt" ]; then
        system_info=$(head -20 "$HOME/.ai-memory/knowledge-base/system-info.txt" 2>/dev/null)
    fi
    
    # Load relevant knowledge base snippets
    kb_snippets=""
    if [ -d "$HOME/.ai-memory/knowledge-base" ]; then
        kb_count=$(find "$HOME/.ai-memory/knowledge-base" -type f | wc -l 2>/dev/null || echo 0)
        kb_size=$(du -sh "$HOME/.ai-memory/knowledge-base" 2>/dev/null | cut -f1 || echo "0")
        kb_snippets="[User has $kb_count files indexed in knowledge base (${kb_size})]"
    fi

    printf '%s\n' "System Instructions:
$system

User Profile:
$profile

System Information:
$system_info

Recent Bash History:
$bash_history

Knowledge Base:
$kb_snippets

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

    LOG_DIR="$HOME/.ai-memory/var"
    mkdir -p "$LOG_DIR"
    PID_FILE="$LOG_DIR/ollama-ava.pid"

    # Function to check if Ollama server responds to 'ollama list'
    ollama_responding() {
        if ollama list >/dev/null 2>&1; then
            return 0
        fi
        return 1
    }

    # If server not responding, try start with retries
    if ! ollama_responding; then
        printf '%b\n' "${YELLOW}🔄 Starting local Ollama service...${NC}" >&2
        setsid ollama serve >"$LOG_DIR/ollama-ava.log" 2>&1 &
        echo "$!" > "$PID_FILE" || true

        # Wait for server to become responsive with backoff
        local tries=0
        local max_tries=8
        local delay=1
        while ! ollama_responding && [ "$tries" -lt "$max_tries" ]; do
            sleep "$delay"
            tries=$((tries + 1))
            delay=$((delay * 2))
        done

        if ! ollama_responding; then
            printf '%b\n' "${YELLOW}⚠️ Ollama did not start after retries; continuing but commands may fail.${NC}" >&2
        fi
    fi

    # Ensure model is available; pull if missing (with a short retry)
    if ! ollama list 2>/dev/null | grep -q "qwen3.5:9b"; then
        printf '%b\n' "${YELLOW}📥 Pulling qwen3.5:9b model...${NC}" >&2
        for _ in 1 2 3; do
            ollama pull qwen3.5:9b >"$LOG_DIR/ollama-pull.log" 2>&1 && break || sleep 2
        done
    fi

    # Trap to clean up server started by this script (reads PID from file)
    cleanup_ollama() {
        if [ -f "$PID_FILE" ]; then
            _p=$(cat "$PID_FILE" 2>/dev/null || true)
            if [ -n "$_p" ] && kill -0 "$_p" >/dev/null 2>&1; then
                kill "$_p" || true
            fi
            rm -f "$PID_FILE" || true
        fi
    }
    trap cleanup_ollama EXIT
}

run_model() {
    local user_input="$1"
    local web_context="${2:-}"
    local full_prompt response

    full_prompt=$(build_full_prompt "$user_input" "$web_context")
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
            echo "  exit              - Quit"
            echo "  help              - Show this help"
            echo "  history           - View recent history"
            echo "  memory            - Show memory stats"
            echo "  research <topic>  - Search online for a topic"
            echo "  github            - Sync GitHub repo info (Avalhla-v0.1)"
            echo "  clear             - Clear screen"
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
        research*)
            # Handle "research <topic>" command
            topic="${prompt#research }"
            topic="${topic# }"  # Remove leading spaces
            
            if [ -z "$topic" ]; then
                echo -e "${RED}Please provide a topic to research. Example: research bash loops${NC}"
                continue
            fi
            
            echo -e "${YELLOW}🔍 Searching online for: $topic${NC}"
            web_context=$(fetch_web_content "$topic" || echo "No internet connection available. Provide my best knowledge instead.")
            
            if [ -n "$web_context" ]; then
                echo -e "${YELLOW}📚 Found web results. Analyzing...${NC}"
            fi
            
            # Ask AI to research the topic with web context
            response=$(run_model "Research this topic: $topic" "$web_context")
            
            if [[ -z "${response//[[:space:]]/}" ]]; then
                echo -e "${YELLOW}⚠️ AI returned no results. Try again.${NC}"
                echo ""
                continue
            fi
            
            echo -e "${GREEN}AI (Research):${NC} $response"
            echo ""
            
            save_conversation "research: $topic" "$response"
            continue
            ;;
        "github")
            echo -e "${YELLOW}🌐 Syncing GitHub repo: VVgbon916/Avalhla-v0.1${NC}"
            if command -v "$HOME/bin/ai-github-sync" >/dev/null 2>&1; then
                "$HOME/bin/ai-github-sync"
            else
                echo -e "${RED}ai-github-sync not found. Please initialize the AI first.${NC}"
            fi
            
            # After syncing, provide summary
            echo ""
            echo -e "${GREEN}✓ GitHub sync complete! Ask me about:${NC}"
            echo "  • Avalhla-v0.1 project structure"
            echo "  • Recent commits and changes"
            echo "  • Open issues or pull requests"
            echo "  • Project README and documentation"
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

echo "📚 Indexing your code, documents, and system info..."
echo ""

mkdir -p "$KB_DIR"

# Index custom project path if provided
if [ -n "$PROJECT_PATH" ] && [ "$PROJECT_PATH" != "." ]; then
    echo "📂 Indexing project: $PROJECT_PATH"
    cd "$PROJECT_PATH" 2>/dev/null || { echo "⚠️ Invalid project path: $PROJECT_PATH"; }
fi

# Index Downloads folder
if [ -d "$HOME/Downloads" ]; then
    echo "📂 Indexing Downloads..."
    find "$HOME/Downloads" -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.txt" -o -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) ! -path "*/\.*" 2>/dev/null | while read -r f; do
        rel_path="${f#$HOME/}"
        dest="$KB_DIR/$rel_path"
        mkdir -p "$(dirname "$dest")"
        cp "$f" "$dest" 2>/dev/null || true
    done
fi

# Index Documents folder
if [ -d "$HOME/Documents" ]; then
    echo "📂 Indexing Documents..."
    find "$HOME/Documents" -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.txt" -o -name "*.md" -o -name "*.json" \) ! -path "*/\.*" 2>/dev/null | while read -r f; do
        rel_path="${f#$HOME/}"
        dest="$KB_DIR/$rel_path"
        mkdir -p "$(dirname "$dest")"
        cp "$f" "$dest" 2>/dev/null || true
    done
fi

# Index Avalhla project folder
if [ -d "$HOME/Avalhla-v0.1" ]; then
    echo "📂 Indexing Avalhla-v0.1 (local)..."
    find "$HOME/Avalhla-v0.1" -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.txt" -o -name "*.md" \) ! -path "./node_modules/*" ! -path "./.git/*" ! -path "./__pycache__/*" 2>/dev/null | while read -r f; do
        rel_path="${f#$HOME/}"
        dest="$KB_DIR/$rel_path"
        mkdir -p "$(dirname "$dest")"
        cp "$f" "$dest" 2>/dev/null || true
    done
fi

# Index GitHub repo (VVgbon916/Avalhla-v0.1)
echo "🌐 Fetching GitHub repository info (VVgbon916/Avalhla-v0.1)..."
GITHUB_REPO_DIR="$KB_DIR/github-avalhla-v0.1"
mkdir -p "$GITHUB_REPO_DIR"

# Fetch README
if command -v curl >/dev/null 2>&1; then
    echo "📄 Fetching README..."
    curl -s "https://raw.githubusercontent.com/VVgbon916/Avalhla-v0.1/main/README.md" > "$GITHUB_REPO_DIR/README.md" 2>/dev/null || true
    
    # Fetch repo info
    echo "📋 Fetching repository metadata..."
    curl -s "https://api.github.com/repos/VVgbon916/Avalhla-v0.1" > "$GITHUB_REPO_DIR/repo-info.json" 2>/dev/null || true
fi

# If the repo exists locally with .git, fetch latest info
if [ -d "$HOME/Avalhla-v0.1/.git" ]; then
    echo "📝 Extracting git history..."
    (
        cd "$HOME/Avalhla-v0.1" 2>/dev/null || exit
        git log --oneline -20 > "$GITHUB_REPO_DIR/recent-commits.txt" 2>/dev/null || true
        git remote -v > "$GITHUB_REPO_DIR/git-remotes.txt" 2>/dev/null || true
    ) || true
fi

# Index bash history
echo "📜 Indexing bash history..."
if [ -f "$HOME/.bash_history" ]; then
    cp "$HOME/.bash_history" "$KB_DIR/bash_history.txt" 2>/dev/null || true
fi

# Get system info and store it
echo "🖥️  Capturing system info..."
{
    echo "=== SYSTEM INFORMATION ==="
    echo "Hostname: $(hostname)"
    uname -a 2>/dev/null || true
    echo ""
    echo "=== USER INFO ==="
    id
    echo ""
    echo "=== DISK USAGE ==="
    df -h 2>/dev/null | head -5
    echo ""
    echo "=== AVAILABLE COMMANDS ==="
    compgen -c 2>/dev/null | sort -u | head -50
} > "$KB_DIR/system-info.txt" 2>/dev/null || true

files_count=$(find "$KB_DIR" -type f 2>/dev/null | wc -l || echo 0)
echo ""
echo "✓ Files indexed: $files_count"
echo "✓ AI will reference your code, documents, and system from now on!"
AILEARN

chmod +x "$HOME/bin/ai-learn"
echo "✓ ai-learn command created"

################################################################################
# SECTION 5B: GITHUB SYNC - KEEP REPO INFO UP TO DATE
################################################################################

echo "=== SETTING UP GITHUB SYNC ==="

cat > "$HOME/bin/ai-github-sync" << 'AIGITHUBSYNC'
#!/bin/bash

KB_DIR="$HOME/.ai-memory/knowledge-base"
GITHUB_REPO_DIR="$KB_DIR/github-avalhla-v0.1"
REPO_OWNER="VVgbon916"
REPO_NAME="Avalhla-v0.1"

echo "🌐 Syncing GitHub repository: $REPO_OWNER/$REPO_NAME"
echo ""

mkdir -p "$GITHUB_REPO_DIR"

# Fetch README from main branch
echo "📄 Fetching README.md..."
if command -v curl >/dev/null 2>&1; then
    curl -s "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/main/README.md" \
        -o "$GITHUB_REPO_DIR/README.md" 2>/dev/null && echo "✓ README.md" || echo "⚠️ Could not fetch README"
fi

# Fetch repository metadata (stats, description, etc.)
echo "📋 Fetching repository metadata..."
if command -v curl >/dev/null 2>&1; then
    curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME" \
        -o "$GITHUB_REPO_DIR/repo-metadata.json" 2>/dev/null && echo "✓ Repo metadata" || echo "⚠️ Could not fetch metadata"
fi

# Fetch recent commits
echo "📝 Fetching recent commits..."
if command -v curl >/dev/null 2>&1; then
    curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/commits?per_page=20" \
        -o "$GITHUB_REPO_DIR/recent-commits.json" 2>/dev/null && echo "✓ Commit history" || echo "⚠️ Could not fetch commits"
fi

# Fetch open issues
echo "🐛 Fetching open issues..."
if command -v curl >/dev/null 2>&1; then
    curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues?state=open" \
        -o "$GITHUB_REPO_DIR/open-issues.json" 2>/dev/null && echo "✓ Open issues" || echo "⚠️ Could not fetch issues"
fi

# Fetch open pull requests
echo "📢 Fetching pull requests..."
if command -v curl >/dev/null 2>&1; then
    curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls?state=open" \
        -o "$GITHUB_REPO_DIR/open-prs.json" 2>/dev/null && echo "✓ Open PRs" || echo "⚠️ Could not fetch PRs"
fi

# If local repo exists, extract git info
if [ -d "$HOME/Avalhla-v0.1/.git" ]; then
    echo "📂 Extracting local git information..."
    (
        cd "$HOME/Avalhla-v0.1" 2>/dev/null || exit
        
        # Recent commits
        git log --oneline -30 --decorate > "$GITHUB_REPO_DIR/git-log.txt" 2>/dev/null || true
        
        # Remote info
        git remote -v > "$GITHUB_REPO_DIR/git-remotes.txt" 2>/dev/null || true
        
        # Branches
        git branch -a > "$GITHUB_REPO_DIR/git-branches.txt" 2>/dev/null || true
        
        # Current status
        git status > "$GITHUB_REPO_DIR/git-status.txt" 2>/dev/null || true
    ) || true
    
    echo "✓ Local git info extracted"
fi

echo ""
echo "✓ GitHub repo synced! AI has access to:"
echo "  • Repository README and documentation"
echo "  • Recent commits and history"
echo "  • Open issues and pull requests"
echo "  • Local git information"
echo ""
echo "Run 'ai-github-sync' anytime to refresh this data."
AIGITHUBSYNC

chmod +x "$HOME/bin/ai-github-sync"
echo "✓ ai-github-sync command created"

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
    cat "$HOME/.ai-memory/profiles/user-profile.txt" 2>/dev/null || true
    echo ""
    echo "=== RECENT CONVERSATIONS ==="
    find "$MEMORY_DIR" -name "*.jsonl" -exec grep -h '"user"' {} \; 2>/dev/null | tail -20 || true
)

prompt_text="Based on this conversation history with your user, what have you learned about them?\n$memory_text\n\nProvide a concise summary."

# Use a prompt file to avoid quoting issues
prompt_file=$(mktemp)
printf '%s' "$prompt_text" > "$prompt_file"

echo "AI's understanding of you:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Try running with prompt file first, fallback to inline
ollama run "$MODEL" "$prompt_file" 2>/dev/null || ollama run "$MODEL" "$(cat "$prompt_file")" 2>/dev/null || true
rm -f "$prompt_file" || true
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
