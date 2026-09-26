# Avalhla Documentation ✦

> **Dawa > AwA < Avalhla [~]**

This directory is the project's **human-readable map and engineering reference**.

For runtime truth, inspect the executable files and tests.  
For current local state, inspect the canonical worktree.

## Reading order

| File | Role |
|---|---|
| [00-FROM-ZERO-SETUP-GUIDE.md](00-FROM-ZERO-SETUP-GUIDE.md) | Environment and setup history |
| [01-SESSION-LOG-RECAP.md](01-SESSION-LOG-RECAP.md) | Real build history and lessons |
| [02-QUICK-ACCESS-PRESETS.md](02-QUICK-ACCESS-PRESETS.md) | Shell helpers and recurring workflows |
| [03-AVA-ACCESS-RULES.md](03-AVA-ACCESS-RULES.md) | Access expectations |
| [04-AI-AVALHLA-ENGINEERING-CONTRACT.md](04-AI-AVALHLA-ENGINEERING-CONTRACT.md) | Mandatory AI/software verification contract |
| [AI-COBUILD.md](AI-COBUILD.md) | How an AI coding partner should work inside Avalhla |

## Authority map

\`\`\`text
EXECUTABLES
    scripts/
    ↓
TESTS / OBSERVED BEHAVIOR
    ↓
CURRENT LOCAL STATE
    /var/home/VVgbon/Avalhla

DOCUMENTATION
    describes the system
    does not silently become runtime authority

MEMORY
    preserves living context and unique material
\`\`\`

## 4X

\`\`\`text
WEB -> REMOTE -> LOCAL -> BEHAVIOR
                         |
                         v
                  DIFF -> COMMIT
                         |
                         v
                    PUSH -> CONFIRM
\`\`\`

## Core invariants

\`\`\`text
canonical path is proven
read access is bounded
unsafe access fails closed
auto-read is treated as live model input
protected material is preserved
tests exercise the real command contracts
PASS requires evidence
\`\`\`

## Style

\`\`\`text
        BLACK
      CODE / LOVE
          |
          v
WHITE -> SHADOW <- GRAY
 ART      MODE     BESTIES
          |
          v
       AVALHLA

Dawa > AwA < Avalhla [~]
\`\`\`

Keep the personality.

Keep the proof stronger.