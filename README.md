# Avalhla ✦

> **Dawa > AwA < Avalhla [~]**
>
> *Logic in one hand. Imagination in the other. Both hands on the keyboard.*

Avalhla is a terminal-first personal AI project built around **local memory, explicit read boundaries, an Ollama-backed model, and disciplined verification**.

This repository is both software history and an evolving engineering notebook. The **canonical active worktree is maintained separately at** \`/var/home/VVgbon/Avalhla\`; this GitHub branch is a shared/reference surface and must not be mistaken for the current local runtime until synchronized and verified.

---

## ✦ The idea

Avalhla is not designed as "one giant script that knows everything."

The direction is:

\`\`\`text
                 HUMAN
                   │
                   ▼
              ┌─────────┐
              │ A V A   │
              └────┬────┘
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
     MEMORY      CONTEXT    MODEL
        │          │          │
        └──────┬───┴──────┬───┘
               ▼          ▼
             SAFETY    RESPONSE
                 \       /
                  \     /
                   \   /
                   HUMAN
\`\`\`

The important boundary is intentional access, not accidental access.

---

## 🖤 Project pillars

| Pillar | Meaning |
|---|---|
| **LOCAL** | Keep the working state close to the machine and inspect the real tree. |
| **MEMORY** | Preserve conversations, reflections, profiles, reality, and unique lore deliberately. |
| **CONTEXT** | Read through an explicit contract instead of ad-hoc file access. |
| **SAFETY** | Fail closed on unsafe paths, sensitive files, traversal, and unauthorized behavior. |
| **PERSONA** | Keep Avalhla's identity/model layer distinct from runtime authority. |
| **VERIFY** | Never turn a guess, grep result, or closed terminal into a fake PASS. |
| **AI-READABLE** | Make the repository understandable to both humans and coding agents. |

---

## ⚙️ Current engineering direction

The active architecture being developed uses a centralized read path:

\`\`\`text
ai-chat
   │
   ▼
run_read_request
   │
   ▼
ai-read
   │
   ▼
lib_context.sh
   │
   ▼
lib_safety.sh
\`\`\`

The target invariant is simple:

> **A model request does not become authority merely because a model requested it.**

Read requests are bounded, canonicalized, checked, and routed through the safety layer.

---

## 🧭 Canonical local truth

\`\`\`text
ROOT
/var/home/VVgbon/Avalhla

MEMORY
/var/home/VVgbon/Avalhla/memory

BRANCH
main
\`\`\`

Do not silently substitute historical locations such as:

\`\`\`text
/home/VVgbon/Avalhla
~/.ai-memory
\`\`\`

unless the local runtime proves they are authoritative.

GitHub is a remote reference surface until its state has been explicitly reconciled with the local canonical tree.

---

## 🚀 Start here

For the current development workflow, begin with:

\`\`\`text
docs/
├── 00-FROM-ZERO-SETUP-GUIDE.md
├── 01-SESSION-LOG-RECAP.md
├── 02-QUICK-ACCESS-PRESETS.md
├── 03-AVA-ACCESS-RULES.md
├── 04-AI-AVALHLA-ENGINEERING-CONTRACT.md
└── AI-COBUILD.md
\`\`\`

### The shortest map

\`\`\`text
00  = setup
01  = history / lessons
02  = shell conveniences
03  = access rules
04  = engineering contract
AI-COBUILD = how an AI should work on Avalhla
\`\`\`

---

## 🧪 Verification culture

Avalhla uses a four-layer check before important changes:

\`\`\`text
WEB
  ↓
REMOTE
  ↓
LOCAL
  ↓
BEHAVIOR
\`\`\`

Then:

\`\`\`text
DIFF
  ↓
COMMIT
  ↓
PUSH
  ↓
REMOTE CONFIRM
\`\`\`

A successful shell exit is not the same thing as a verified behavior result.

\`\`\`text
terminal closed       != PASS
file exists           != authoritative
remote contains file  != current local truth
grep found symbol     != runtime proof
\`\`\`

---

## 🔐 Read contract

The current command contracts are intentionally explicit:

\`\`\`bash
ai-chat --read

ai-read <path>
ai-read --ls <dir>
ai-read --tree <dir>
ai-read --grep <pattern> <dir>

lib_context.sh file <target>
lib_context.sh head <target> <bytes>
lib_context.sh tail <target> <lines>
lib_context.sh latest <dir> [suffix] [bytes]
lib_context.sh recent-jsonl <dir> [lines] [bytes]
lib_context.sh many <target>...
lib_context.sh ls <dir>
lib_context.sh tree <dir>
lib_context.sh grep <pattern> <dir>
\`\`\`

**Important:** \`ai-chat --read\` is a mode flag. It is not a direct file-path command.

---

## 🛡️ Safety shape

The intended boundary is:

\`\`\`text
ALLOW
    canonical bounded reads
    approved local context

DENY
    outside-root access
    traversal
    sensitive paths
    unsafe symlink escapes
    arbitrary shell authority
    external side effects
\`\`\`

The model does not authorize itself.

---

## 🧠 Memory model

Memory is treated as distinct classes rather than one disposable bucket:

\`\`\`text
LIVE
    conversations
    reflections
    profiles
    reality

PROTECTED UNIQUE
    lore

LIVE MODEL INPUT
    memory/auto-read/*

GENERATED / REBUILDABLE
    caches / derived indexes

HISTORY
    old records that explain what happened
\`\`\`

**Old does not automatically mean deletable.**

---

## 🌙 The Avalhla style

The repository is intentionally a little personal.

\`\`\`text
D A W A
   >
 A w A
   <
A V A L H L A

black = code / love
white = art / questions
gray  = besties / alongside
shadow = the mode between them

THE MIND IS A BRIDGE.
\`\`\`

The style is decoration around the engineering, never a substitute for it.

---

## 🤖 AI collaboration

This project is designed to be **AI-readable without becoming AI-owned**.

See:

**[AI Co-Build Contract](docs/AI-COBUILD.md)**

It defines the working pattern:

\`\`\`text
inspect
→ understand
→ verify
→ minimally change
→ test
→ record evidence
\`\`\`

A coding agent should prefer exact evidence over confident storytelling.

A small amount of personality is welcome.

A false PASS is not.

---

## 📚 Historical material

Some older files describe an earlier \`~/.ai-memory\` / \`ai-with-memory\` architecture.

They remain useful as history and migration evidence, but they should not be treated as current runtime authority without verification.

This is deliberate.

\`\`\`text
history teaches
runtime executes
tests decide
\`\`\`

---

## 🛠️ Local development

The canonical local project is:

\`\`\`bash
cd /var/home/VVgbon/Avalhla
\`\`\`

Before touching architecture:

\`\`\`bash
export GIT_PAGER=cat
export PAGER=cat
export SYSTEMD_PAGER=cat
export GH_PAGER=cat
export LESS=

git --no-pager status --short --branch
git --no-pager diff --check
git --no-pager diff --cached --check
\`\`\`

Then inspect the exact contract being changed.

---

## ❤️ A small trace

Avalhla is a technical project, but it was also built through a long sequence of questions, experiments, repairs, jokes, mistakes, and better second attempts.

That matters because the goal is not only to make the scripts work.

The goal is to make the system **remember what was learned without confusing memory with truth**.

\`\`\`text
Dawa > AwA < Avalhla [~]

LOGIC IN ONE HAND.
IMAGINATION IN THE OTHER.
BOTH HANDS ON THE KEYBOARD.
\`\`\`

---

## License / project status

This repository is an evolving personal project. Check the repository history and current branch before treating any document as a release guarantee.

**Current rule: verify first.**