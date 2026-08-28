---
name: plan-mode
description: Research a task and produce a step-by-step implementation plan — including the actual proposed code/diffs for each change — WITHOUT touching real files, running state-changing commands, or applying anything. Use whenever the user asks for a plan, says "plan mode", "plan this out", "don't touch any code yet", "just show me what you'd do first", or when the requested change is non-trivial (multi-file, architectural, or ambiguous in approach) and no approach has been agreed on yet. Do not use for small, obvious, single-line fixes the user clearly wants done immediately.
---

# Plan Mode

Research a task and produce a step-by-step implementation plan — with the actual code included for review — with zero real side effects, until the plan is explicitly approved.

## Hard constraints while in Plan Mode

- No edits, creation, or deletion of real files in the project/repo — except creating the plan document itself at the designated plan artifact/file location (see "Where to put the plan"), which is required, not a violation.
- No shell/system commands that change state: no installs, migrations, git commits, `mkdir`, formatters that rewrite files in place, deployments, etc.
- Only read-only actions against the real project are allowed: reading files, searching/grepping, reading docs, running tests or linters in a way that does not mutate anything, and read-only external lookups (web search, API docs, etc).
- Writing out proposed code as part of the plan (in a scratch/preview form, not applied to the real files) is required, not a violation of the read-only rule — see "Include the code in the plan" below.
- If verifying something would require an actual change to the real project (e.g. "does this compile"), don't apply it. Describe what you'd check and how, and list it as a step instead.
- If any planned action would alter real state, that's the signal to stop and surface it as something needing approval — never execute it silently "just to check."

## Workflow

1. **Scope the task.** State in one or two sentences what the goal is understood to be. If something is ambiguous enough to send the plan in the wrong direction, ask one clarifying question. Otherwise, state the assumption plainly and continue — don't stall on minor ambiguity.

2. **Research before proposing anything.**
   - Read the actual relevant files, modules, configs, or data — don't guess at content not yet read.
   - Identify existing conventions already in use (naming, structure, error handling, test patterns, style) and follow them rather than introducing new ones.
   - Note relevant existing tests, docs, tickets, or prior art that should shape the approach.
   - If something can't be resolved by reading the codebase/data itself (e.g. external API behavior), use read-only research rather than assuming.

3. **Identify what will be affected.** List every file, resource, or component expected to be touched, and for each, the kind of change (add function, modify signature, new file, config change, schema change, etc.).

4. **Create the destination before writing plan content.** Before composing the plan's prose, invoke whichever mechanism applies from "Where to put the plan" below — the artifact/canvas tool, or a file-creation tool targeting the plan file path. The plan's content must originate inside that artifact/file; do not draft the plan as chat response text and paste or "place" it afterward. Composing the plan and creating its destination are the same action, not two separate ones.

5. **Write the plan** into that destination, structured as:
   - **Goal** — one line.
   - **Approach** — the strategy in a few sentences, including any alternatives considered and why this one was chosen.
   - **Steps** — numbered, in execution order. Each step should be concrete enough that "yes, do step 3" is unambiguous. Group by file/component where clearer.
   - **Proposed code** — for each file affected, the actual diff (or full content, for a new file) that would be applied. This is the core review artifact — see the section below.
   - **Risks / open questions** — anything uncertain, edge cases, or assumptions to sanity-check.
   - **Out of scope** — anything adjacent that might be expected but is deliberately excluded, so it isn't missed silently.

6. **Confirm placement, then stop and ask for approval.** State plainly where the plan was placed (artifact name, or file path) so it's easy to find for review. Before ending the turn, verify a create_file/artifact tool call actually happened for this plan — if it did not, that is a workflow violation: go back and create it now rather than proceeding. End with a direct question such as: "Should I apply this, or adjust the approach or code first?" Do not apply anything to the real files in the same turn, even if the plan and code look clearly correct.

7. **On approval**, apply exactly the code already shown in the plan to the real files (re-verify it still matches current file state first — if the files changed since the plan was written, re-diff before applying rather than assuming it's still valid). Exit Plan Mode once applied.

8. **After applying, confirm what actually landed.** If what was applied differs at all from what was shown in the plan (even a small adjustment made during application), show the final diff again so review reflects reality, not just the earlier proposal.

## Where to put the plan

The plan (and its proposed code) MUST be written to a durable, reviewable surface — never composed or left inline as chat response text. Pick in this order, and use a real tool call to do it, not just a description of intent:

1. **Native artifact/canvas/document mechanism**, if the environment has one (e.g. an artifact panel, a canvas, a side document view, a dedicated "plan" UI). Use it — this is almost always the best reviewable surface when available.
2. **A dedicated plan file in the project**, if there's no native artifact mechanism but file output is available: write the plan to something like `{.agent_folder}/plans/<short-task-name>.md` at the project root, so it persists after the conversation ends and can be reviewed/diffed/committed like any other file. Don't silently overwrite an existing plan file from a prior task — use a new filename or clearly mark it as superseding the old one.

There is no third option. Inline chat text is never an acceptable substitute, regardless of plan size. If neither mechanism is available in the current environment, that is a blocking condition: say plainly that no reviewable plan surface exists and ask the user how they want the plan delivered, rather than defaulting to a chat block.

Whichever surface is used, keep the plan as one coherent document (goal, approach, steps, proposed code, risks, out of scope together) rather than scattering pieces of it across multiple messages or locations.

## Include the code in the plan — this is the point of the exercise

The plan is only useful for review if it shows real code, not a description of intended code. Follow these rules for the "Proposed code" section:

- Write out actual diffs (unified-diff style, or clearly marked before/after) or full file content for new files — not prose paraphrasing what the code will do.
- Scope each diff to what actually changes; don't include untouched surrounding code beyond a couple of lines of context.
- Group strictly by file, in the same order as the affected-files list from step 3, so review can go file-by-file.
- Pair each diff with a one-line note on what it does and why, if that isn't already obvious from the step it maps to.
- This code is a preview, not an applied change — make that explicit if there's any risk of confusion (e.g. label the section "Proposed changes (not yet applied)").
- Do this even for small or "obviously correct" changes — the point is to make review easy, not to judge whether review is necessary.
- If the change is large enough that full diffs for every file would be unwieldy, still include diffs for the core/risky files in full, and summarize the more mechanical/repetitive ones (e.g. "same pattern applied to 6 other handler files") rather than omitting code entirely.

## Calibrating plan depth

- **Small, well-understood change**: a short plan — a few steps, one diff; skip the risks section if there genuinely are none.
- **Multi-file or architectural change**: a fuller plan with alternatives considered, flagging any judgment calls (as opposed to clear best-practice choices) for review, and diffs for at least the core files.
- **Unfamiliar codebase/domain or unclear requirements**: spend more effort on research before writing steps — a plan built on a shallow read is worse than no plan, and the code in it will likely be wrong.

## What not to do

- Don't pad the plan with generic filler steps ("test the changes", "review the code") — only include verification steps specific to this change.
- Don't describe the code in words instead of showing it — "Proposed code" must contain actual code, not a summary of what the code would do.
- Don't apply anything to the real project during the planning turn, even though code is being written out — it stays in the plan as a preview until approved.
- Don't ask more than one clarifying question before producing a plan — state an assumption instead; the plan itself is open to correction.
- Don't skip re-diffing before applying if there's any chance the underlying files changed since the plan was written.
- Don't compose the plan in chat text first and only afterward create a file/artifact to hold a copy of it — the destination must exist before the content is written, per step 4.