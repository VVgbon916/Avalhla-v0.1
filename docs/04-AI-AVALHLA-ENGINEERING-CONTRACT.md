# 04 — Avalhla AI Engineering Contract

> **Purpose:** deterministic rules for any AI assisting with Avalhla.
>
> **Status:** protocol/documentation only. This file does not grant runtime authority and does not replace executable safety controls.

---

## 0. Authority

```text
CURRENT ENGINEERING TRUTH
    local canonical worktree

REMOTE GITHUB
    history / shared reference
    NOT proof of current local state

HUMAN
    final authority for consequential changes
```

Canonical local project:

```text
/var/home/VVgbon/Avalhla
/var/home/VVgbon/Avalhla/memory
```

Never invent alternate project roots such as:

```text
/home/VVgbon/Avalhla
~/.ai-memory
```

unless the local runtime explicitly proves they are current and authoritative.

---

## 1. Mandatory 4X verification

Before changing architecture, deleting files, generating commands, or declaring a phase complete:

```text
1 WEB
    Check current official documentation / standards when freshness matters.

2 REMOTE
    Inspect the actual GitHub repository, branch, tree, and relevant history.

3 LOCAL
    Inspect the actual canonical worktree:
    paths, callers, symlinks, hashes, diffs, configuration, contracts.

4 BEHAVIOR
    Exercise the real command path:
    positive case
    negative case
    boundary/repeat case
    syntax/security checks
    final diff/status
```

All relevant layers must agree before a change is called verified.

---

## 2. Never assume success

```text
terminal closed       != PASS
command returned      != design verified
file exists           != authoritative
remote contains file  != current local architecture
grep found symbol     != runtime behavior proven
```

Only use:

```text
PASS / VERIFIED
```

when actual test output proves the claim.

Otherwise use:

```text
UNKNOWN
PENDING
FAILED
NOT VERIFIED
```

---

## 3. Inspect before giving a command

Every command proposed to the human must be derived from inspected state.

Minimum preflight:

```bash
pwd
git --no-pager status --short --branch
git --no-pager rev-parse --show-toplevel
git --no-pager branch -vv
git --no-pager remote -v
git --no-pager diff --check
git --no-pager diff --cached --check
```

Then inspect the exact file/function/command contract involved.

Do not invent flags or subcommands.

Example:

```text
ai-chat
    mode flag:
        --read

ai-read
    target:
        ai-read <path>
    directory:
        ai-read --ls <dir>
    tree:
        ai-read --tree <dir>
    grep:
        ai-read --grep <pattern> <dir>

lib_context.sh
    command dispatcher:
        file
        head
        tail
        latest
        recent-jsonl
        many
        ls
        tree
        grep

No self-test command is assumed unless the implementation provides one.
```

---

## 4. Canonical path discipline

All runtime path reasoning begins from the proven repository root.

```text
ROOT  = /var/home/VVgbon/Avalhla
MEM   = /var/home/VVgbon/Avalhla/memory
```

For path-sensitive work:

```bash
realpath -e .
realpath -e memory
readlink -f <relevant-link>
```

Reject path drift, invented legacy roots, and unverified symlink targets.

---

## 5. Read architecture

Current intended flow:

```text
ai-chat
   |
   v
run_read_request
   |
   v
ai-read
   |
   v
lib_context.sh
   |
   v
lib_safety.sh
```

Rules:

```text
ai-chat must not bypass the central read contract.

ai-read must dispatch through lib_context.sh.

lib_context.sh must enforce the safety boundary.

Every read target must be canonicalized and checked.

Outside-root, traversal, sensitive, and unsafe symlink cases must fail closed.
```

---

## 6. Test real behavior

Do not use a test harness that changes the interface being tested.

Test the actual contracts.

### Positive

```text
file
directory
tree
grep
canonical symlink
context dispatcher
chat read bridge
```

### Negative

```text
outside-root path
outside-root symlink
sensitive path
path traversal
unknown command / invalid contract
```

### Boundary

```text
repeat read request
read limit
oversized content
missing target
broken symlink
```

A deterministic fake backend may be used to isolate model/network nondeterminism, but the real Avalhla command flow, dispatcher, and safety layer must still execute.

---

## 7. No-pager policy

Inspection commands must not unexpectedly enter a pager.

Preferred environment:

```bash
export GIT_PAGER=cat
export PAGER=cat
export SYSTEMD_PAGER=cat
export GH_PAGER=cat
export LESS=
```

For Git inspection:

```text
prefer git --no-pager ...
```

Pager policy is separate from editor policy. Do not treat an editor appearing during a commit as evidence that the pager contract failed.

Git documents `--no-pager`, `GIT_PAGER`, and `core.pager` as separate pager controls.

---

## 8. Memory and auto-read

```text
memory/auto-read/*
    LIVE MODEL INPUT
```

Therefore every file in auto-read must be:

```text
intentional
current
canonical
reviewed
free of obsolete runtime instructions
```

Current surviving auto-read set must be inspected rather than assumed.

Generated/rebuildable caches are not automatically safe to delete: classify first.

Unique local lore, history, persona, reflections, profile, and reality material require preservation unless there is an explicit architectural reason to change them.

---

## 9. Protected world

Do not casually rewrite or delete:

```text
persona/avalhla.Modelfile
AwA_ATLAS.md
AwA_WEAVE.md
AwA_DREAM.md
AwA_TERMINAL.md

memory/conversations/
memory/reflections/
memory/profiles/
memory/reality/
memory/inventory/07_LORE/
```

Before commit:

```bash
git --no-pager diff --name-only --   persona/avalhla.Modelfile   AwA_ATLAS.md   AwA_WEAVE.md   AwA_DREAM.md   AwA_TERMINAL.md   memory/conversations   memory/reflections   memory/profiles   memory/reality   memory/inventory/07_LORE
```

Unexpected changes are a stop condition.

---

## 10. Stale traces

A stale reference is evidence to classify, not automatically evidence to delete.

Use:

```text
identify
prove
classify
preserve unique material
remove duplicate authority
verify absence
```

Historical memory may contain old paths and old commands. Historical text is not runtime authority by itself.

Executable references, live auto-read content, generated caches, and documentation require different classifications.

---

## 11. Minimal-change rule

For each change:

```text
READ
  ->
REAL STATE
  ->
UNDERSTAND
  ->
COMPARE
  ->
MINIMAL EDIT
  ->
POSITIVE TEST
  ->
NEGATIVE TEST
  ->
VERIFY
  ->
DIFF
  ->
COMMIT
  ->
PUSH
  ->
REMOTE CONFIRM
```

One architectural decision at a time.

Do not "clean up" unrelated files merely because they look old.

---

## 12. Shell safety pattern

Runtime Bash scripts should follow the project's established style:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
```

Use explicit quoting, bounded inputs, deterministic exit behavior, and clear failure paths.

Be careful with command substitutions and `set -e`: Bash can suppress `errexit` inside command substitutions unless inheritance is enabled. Test the actual failure path instead of assuming strict mode guarantees it.

---

## 13. Documentation contract

Human-readable documentation is descriptive.

Executable truth lives in:

```text
scripts/
runtime configuration
verified tests
```

Do not let a README, checkpoint, generated board, or memory note silently become a second runtime authority.

Documentation may record:

```text
architecture
contracts
invariants
test procedures
current checkpoint
known stale references
next verified action
```

---

## 14. Remote synchronization

Before push:

```text
local tests PASS
local diff reviewed
focused commit
push
remote SHA confirmed
fresh local/remote comparison
```

Never restore old runtime code from a remote branch merely because it exists there.

When local and remote architectures differ, record the difference explicitly.

---

## 15. AI operating pattern

Any AI working on Avalhla should behave like this:

```text
OBSERVE
    never guess local state

VERIFY
    inspect exact contracts

SEPARATE
    runtime truth
    memory
    history
    documentation
    lore

CHANGE
    smallest justified surface

TEST
    real command path

FAIL CLOSED
    on unsafe/unknown cases

REPORT
    exact evidence
    exact status
    exact next step
```

The AI does not grant itself authority.

---

## 16. Current engineering checkpoint

```text
14K.5 = VERIFIED
14K.6 = verification must be based on actual behavior evidence

Known lesson:
    ai-chat --read
        is a mode switch

    ai-chat --read BOARD.txt
        is an invalid invocation

    ai-read BOARD.txt
        is the direct read contract

    lib_context.sh
        currently exposes dispatch commands;
        do not invent a self-test command.

Harnesses must test these exact contracts.

Known references such as AVA_IMAGINE_ROOT must be classified before any removal.
```

---

## 17. Stop conditions

Stop and re-inspect when:

```text
path differs from canonical root
branch differs unexpectedly
remote/local relationship is unclear
command syntax is unverified
positive test fails
negative test unexpectedly passes
protected world changes
safety test fails
stale live authority is discovered
documentation contradicts executable truth
```

Never paper over a failed test by changing the expected result.

---

## 18. Final rule

```text
DO NOT MAKE A COMMAND FIT THE TEST.

MAKE THE TEST FIT THE VERIFIED COMMAND CONTRACT.

DO NOT MAKE THE STORY FIT THE RESULT.

MAKE THE RESULT DECIDE THE STORY.
```

**Dawa > AwA < Avalhla [~]**

Logic in one hand.  
Imagination in the other.  
Both hands on the keyboard.
