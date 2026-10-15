---
name: write-model-spec
description: Write the build spec for a custom model or fine-tune from the planning docs, plus a draft Hugging Face model card.
---

# Write the model spec

Synthesises the planning docs into `docs/spec.md`, the document someone (or an
agent) builds from, plus a draft model card. A spec someone could start building
from is the end of planning.

Plugin references live at `../../references/` relative to this skill's directory.

## Inputs

- Everything in `docs/`: requirements, prior-art, options, base-model, data-plan,
  eval-plan, decisions. Check `project.json` for skipped stages.

## Steps

1. **Gap check.** List any stage that is `todo` and that the spec needs. For a
   fine-tune that means framing, approaches, base model, data and evaluation. Run
   the missing skill, or with the user's agreement mark the section `TBD`, with the
   open question, in the spec. Never paper over a gap with invented detail.
2. Write `docs/spec.md`:
   - **Summary**: what the model does, for whom, the verdict and why, in 5 lines.
   - **Task and I/O contract**: from requirements, with the worked examples.
   - **Approach**: the chosen rung, base model (id, revision, licence), and head or
     adapter config.
   - **Data**: sources, volumes, splits, labelling procedure, licence chain. Link
     `data-plan.md` and do not duplicate it.
   - **Training recipe**: framework (transformers Trainer / TRL / sentence-transformers
     / SetFit / NeMo…), key hyperparameters as starting points marked as such,
     hardware and estimated cost, and the experiment tracking to use.
   - **Evaluation**: metrics, baselines, pass bar, slices. Link `eval-plan.md`.
   - **Deliverables**: Hub model repo name (under `hf_owner`), dataset repo if
     publishing, exports (ONNX / GGUF / transformers.js), and a demo Space if wanted.
   - **Milestones**: ordered, each with an exit criterion, e.g. "M1: test set
     frozen", "M2: baseline numbers", "M3: first fine-tune beats baseline".
   - **Risks and open questions**, each dated.
   - **Requirement traceability**: each `FR`/`CR` mapped to the section or milestone
     that satisfies it.
3. Write `docs/model-card-draft.md` in Hub model-card format: YAML front matter
   (`license`, `language`, `pipeline_tag`, `base_model`, `datasets`, `tags`,
   `library_name`) and sections for intended use, out-of-scope use, training data,
   evaluation (placeholders for numbers), limitations, and how to use. Fill
   everything the plan already knows.
4. Update the README's read-in-this-order table and status line. Set
   `project.json` → `stages.spec` done and `status` stays `planning` until data work
   starts. Mirror into the hub registry. Commit and push.
5. Report: the spec's summary, the first milestone, and the first concrete action.
   If a trainer skill is installed (`delegation.md`), name it as the build route.
   Do not start a training run.

## Notes

- The spec is a contract with the future builder. Prefer exact IDs, numbers and
  file paths over prose.
- If the verdict was not a build (`use-existing`, `no-model`, `prompt-an-llm`),
  write a short spec for that: the integration or rules, plus the eval plan. A spec
  is still the right deliverable.
- If the build will live in a separate implementation repo, record it in
  `project.json` → `links.implementation_repo` once created and link it from the README.
