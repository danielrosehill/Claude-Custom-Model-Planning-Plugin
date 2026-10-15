---
name: frame-the-task
description: Turn a model idea into an ML task: task type, I/O contract, labels, constraints and success metric, as numbered requirements.
---

# Frame the task

Converts "I want a model that…" into something a model can be built against. This
is where most planning value sits. A wrong formulation (multi-class when it is
multi-label, document-level when it is token-level) wastes every later stage.

Plugin references live at `../../references/` relative to this skill's directory.
Read `task-taxonomy.md` and `workspace-layout.md`.

## Inputs

- `docs/idea.md` and any exists-check research in the planning repo.
- The user, for questions only they can answer.

## Steps

1. Read the idea and the exists-check results.
2. Work through the formulation questions in `task-taxonomy.md`: unit of decision,
   label set and stability, multi-label vs multi-class, abstain option, which error
   is worse, input length and language mix, where it runs.
   - Answer what the idea already answers.
   - Ask the user **only** what is both unanswered and decision-changing, in one
     batch of at most 4 questions. Make a sensible default for the rest and record it
     as an assumption.
3. If two formulations are viable, write both with their cost difference and
   recommend one. Example: span tagging vs sentence classification + lexicon.
4. Write `docs/requirements.md`:
   - **Task statement**: one sentence plus the pipeline tag.
   - **I/O contract**: input type, max length, encoding and language; output schema
     (JSON) with labels and score semantics. Include **3–5 worked examples**, at
     least one hard case and one negative.
   - **Label definitions**: one line each, with a boundary rule for confusable pairs.
   - Numbered requirements: `FR-n` (functional), `CR-n` (constraints: size budget
     in params, latency, hardware, offline/online, licence intent), `DR-n` (data
     requirements known so far), `NG-n` (explicit non-goals).
   - **Success metric**: the primary metric and why, given which error is worse. The
     numeric bar is set later in `plan-evaluation`.
   - **Assumptions** and **open questions**, each dated.
5. Update `project.json`: `task.*` fields, `stages.framing`, `stage`.
6. Commit. Suggest `survey-prior-art`, or `compare-approaches` if the exists check
   already settled the landscape.

## Notes

- Concrete examples beat abstract definitions. If the user cannot produce an
  input/output example, the task is not ready to frame, so say so.
- The size budget comes from the deployment target, not preference. "Runs in a
  browser tab" and "runs on a 24 GB GPU" are different projects.
- Licence intent belongs here: an Apache-2.0 release forbids non-commercial bases
  and datasets later.
