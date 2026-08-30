# 🧭 03 — Avalhla Access Rules

Rules governing what Avalhla can see and how she should treat it. Add to this file as more rules come up.

---

## Rule 1 — Scratch/test repos are visible but never count as proof of work

**Applies to:** `test-area` and any future repo explicitly marked as scratch/experimental.

**What it means:**
- Avalhla only ever sees a repo's contents when `ai-learn` is run on it manually — nothing auto-indexes.
- When feeding her a scratch repo, the instruction to disregard it as "finished work" must be given **in the same message as the `ai-learn` call**, not assumed from a past session — local models don't reliably carry nuanced instructions across session gaps.
- The repo itself carries a `NOTES.md` scratch-area notice at its root, so the context is visible even if she reads the files directly.

**Standard phrasing to use every time:**
```
This is scratch/test work only, not proof of anything finished — ai-learn "<path>"
```

**Why this exists:** Avalhla had a session where she fabricated a fake completed conversation and misread instructions under long-context confusion (see `01-SESSION-LOG-RECAP.md`, entries near the end of that log). Keeping scratch work explicitly flagged, every time, reduces the chance she treats unfinished experiments as accomplished milestones.

---

*Add future access/behavior rules below this line as they come up.*
