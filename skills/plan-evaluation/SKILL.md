---
name: plan-evaluation
description: Define how a planned model is judged: metrics, eval set, a mandatory no-model baseline and the pass bar, before any training starts.
---

# Plan the evaluation

Decides, before training, what "good enough" means and how it will be measured. A
model project without a pre-committed pass bar ends with "it seems to work".

Plugin references live at `../../references/` relative to this skill's directory.
Read `approach-ladder.md` (the baseline rule) and `delegation.md`.

## Inputs

- `docs/requirements.md` (success metric, which error is worse),
  `docs/data-plan.md` (test split), `docs/options.md` (rung-0 baseline and any
  existing-model candidate).

## Steps

1. **Metrics.** Name the primary metric and justify it from the error asymmetry,
   for example span-level F1 with precision reported separately for a
   conservative detector, or macro-F1 for imbalanced routing. Always report
   precision and recall alongside F1. Add per-label metrics and a confusion matrix
   for classifiers.
2. **Baselines**, all run on the same test set:
   - **Rung 0, no model**: the rules, regex or lexicon from `options.md`, specified
     precisely enough to implement.
   - **Best existing model**, if the exists check found a partial match.
   - **LLM zero-shot or few-shot**, if rung 2 was viable, as a quality ceiling or
     comparison point.
3. **Pass bar.** A numeric threshold on the primary metric and a required margin
   over the best baseline, plus hard constraints: max latency on the target
   hardware, max size, and a minimum score on the hard-negative slice. Write down
   what happens if the bar is missed: iterate on data, try the runner-up base, or
   shelve.
4. **Slices.** Define the subsets reported separately: hard negatives,
   unseen-surface-form split, each language, short and long inputs, and anything
   `requirements.md` flags as risky.
5. **Error analysis protocol.** Decide how many errors get read by hand after each
   run (e.g. 50), and where findings are logged.
6. Write `docs/eval-plan.md` with metrics, baselines (with implementation notes),
   pass bar, slices, error-analysis protocol, and the tool to run it. Use
   `eval-runner` or `huggingface-community-evals` if installed. Otherwise give a
   short script outline. Update `project.json` (`stages.evaluation`). Commit.
7. Suggest `write-model-spec`.

## Notes

- If the verdict was `use-existing` or `no-model`, this plan **is** the remaining
  work. Running it on the user's data decides whether the project is done.
- Set the bar before seeing any model results, and date it. Moving it later must be
  a recorded decision, not a silent edit.
