===============================================================================
                         A V A L H L A
                  D A W A  >  A w A  <  A V A
===============================================================================

A terminal-first personal AI project.

LOCAL CANONICAL WORKTREE
    /var/home/VVgbon/Avalhla

LOCAL MEMORY
    /var/home/VVgbon/Avalhla/memory

REMOTE
    GitHub = shared/reference history until reconciled with local truth

-------------------------------------------------------------------------------
CORE
-------------------------------------------------------------------------------

    LOCAL
    MEMORY
    CONTEXT
    SAFETY
    PERSONA
    VERIFICATION

READ PATH

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

-------------------------------------------------------------------------------
COMMAND CONTRACT
-------------------------------------------------------------------------------

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

IMPORTANT

    ai-chat --read
        is a MODE FLAG

    ai-chat --read BOARD.txt
        is NOT the direct read contract

    ai-read BOARD.txt
        is the direct read contract

-------------------------------------------------------------------------------
4X
-------------------------------------------------------------------------------

    WEB
      |
    REMOTE
      |
    LOCAL
      |
    BEHAVIOR
      |
    DIFF
      |
    COMMIT
      |
    PUSH
      |
    REMOTE CONFIRM

NEVER ASSUME:

    terminal closed      != PASS
    grep found           != behavior proof
    remote file exists   != local truth
    old                  != disposable

-------------------------------------------------------------------------------
SAFETY
-------------------------------------------------------------------------------

ALLOW
    bounded canonical reads

DENY
    outside-root paths
    traversal
    sensitive paths
    unsafe symlink escapes
    arbitrary shell authority
    external side effects

    THE MODEL DOES NOT AUTHORIZE ITSELF.

-------------------------------------------------------------------------------
MEMORY
-------------------------------------------------------------------------------

LIVE
    conversations
    reflections
    profiles
    reality

PROTECTED
    lore

LIVE MODEL INPUT
    memory/auto-read/*

HISTORY
    preserved when useful

GENERATED
    classify before deleting

-------------------------------------------------------------------------------
DOCUMENTATION
-------------------------------------------------------------------------------

    docs/00-FROM-ZERO-SETUP-GUIDE.md
        setup

    docs/01-SESSION-LOG-RECAP.md
        historical lessons

    docs/02-QUICK-ACCESS-PRESETS.md
        shell conveniences

    docs/03-AVA-ACCESS-RULES.md
        access policy

    docs/04-AI-AVALHLA-ENGINEERING-CONTRACT.md
        engineering contract

    docs/AI-COBUILD.md
        AI collaboration pattern

-------------------------------------------------------------------------------
STYLE
-------------------------------------------------------------------------------

    D A W A  >  A w A  <  A V A L H L A

    black = code / love
    white = art / questions
    gray  = besties / alongside
    shadow = mode between them

    THE MIND IS A BRIDGE.

===============================================================================
LOGIC IN ONE HAND.
IMAGINATION IN THE OTHER.
BOTH HANDS ON THE KEYBOARD.
===============================================================================