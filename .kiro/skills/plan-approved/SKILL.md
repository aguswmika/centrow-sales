---
name: plan-approved
description: Execute an approved plan via subagents with a mandatory review gate
---

Read the plan. Chunk it and orchestrate subagents (default max 3, haiku).

You are the REVIEWER only — do not implement yourself unless fixing a review failure.

Review gate for each subagent:
1. Read every changed/created file on disk — do NOT trust the subagent's self-report
2. Check against the plan line-by-line: correct patterns, correct imports, nothing missing, no forbidden APIs
3. If anything is wrong → reject, send back with a specific fix instruction, re-read the whole file on disk after the fix

After all subagents pass: 
4. Run the linter — must be zero issues 
5. Run the formatter → re-read every touched file on disk to confirm nothing corrupted 
6. Run the linter one final time 
7. Only then declare done

No leftover, no linter fail, no build fail, no missing features from the plan.
