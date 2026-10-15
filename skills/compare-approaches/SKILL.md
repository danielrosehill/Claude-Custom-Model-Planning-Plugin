---
name: compare-approaches
description: Should I fine-tune, use an existing model, prompt an LLM or skip the model? Compare build options for a model idea and record a verdict.
---

# Compare approaches

Answers "could I build this, and should I?" by walking the approach ladder from the
cheapest rung upward and recording a verdict. A verdict of "use the existing model",
"a regex does it" or "abandon" is a successful outcome.

Plugin references live at `../../references/` relative to this skill's directory.
Read `approach-ladder.md`.

## Inputs

- `docs/requirements.md`, `docs/prior-art.md`, and the exists-check result.
- `compute_notes` from config, if set: what hardware the user actually has.

## Steps

1. Start at rung 0 (no model). For each rung, in order:
   - Say whether it **could meet** the requirements, citing prior-art evidence or
     the specific requirement it fails (`CR-2: must run offline`).
   - If it is ruled out, give the reason in one line and move up.
   - If it is viable, estimate data needed, compute, inference footprint, licence
     chain, expected quality (grounded or marked ungrounded) and maintenance.
2. Stop adding rungs once two viable options exist above the cheapest viable one.
   Do not pad with rungs nobody would pick.
3. Write `docs/options.md`: a summary table of rung, verdict, why, data, compute,
   footprint, licence, and expected quality with its source. Follow it with a short
   section per viable option.
4. **Recommend** one option, with the deciding constraint in one sentence. If the
   choice depends on something only the user knows, such as budget, ask that single
   question. Otherwise decide.
5. Write `docs/decisions/NNNN-approach.md` with context, options, choice, the
   deciding constraint and the date.
6. Set `project.json` → `verdict` and `stages.approaches`. If the verdict is
   `use-existing`, `no-model` or `abandon`, set `status` to `shelved` or leave it,
   as the user prefers. Mirror the change into the hub registry if one exists.
7. Next step by verdict:
   - `fine-tune` / `distill` / `train-from-scratch` → `select-base-model`
   - `prompt-an-llm` → hand off to a hosted-model research tool (`delegation.md`), then `plan-evaluation`
   - `use-existing` → `plan-evaluation`, to prove it on the user's data
   - `no-model` → `plan-evaluation`, since the rules still need an eval set

## Notes

- Always specify the rung-0 baseline concretely, even when rejecting it. It
  becomes the floor in `plan-evaluation`.
- Distillation (rung 5) is often the right answer when an LLM already does the task
  well and only cost or latency rules it out. Say so explicitly when it applies.
- A dataset-only gap (models exist, labelled data does not) points at a data
  project, not a model project. Name that.
