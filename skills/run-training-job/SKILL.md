---
name: run-training-job
description: Run a training, fine-tuning, sweep or GPU evaluation job for a model project on the user's designated training compute (config `training_compute`, e.g. a general-purpose Modal training app) rather than an ad-hoc or project-unrelated app. Use when the user says "train it", "kick off a training run", "run the fine-tune", "run this on a GPU", or a model project reaches its build phase.
---

# Run a training job

The planning skills end at a spec. When a job actually has to run on a GPU, it goes to
**one designated place**: the training compute named in config `training_compute`. Do not
improvise a new cloud app per job, borrow another project's app, or run training on the
laptop.

Plugin references live at `../../references/` relative to this skill's directory.

## Inputs

- The job: a training script/directory in the model repo, the command that runs it, and a
  run name (`<project>-r<N>` or the project's own naming scheme).
- Config `training_compute` (see `workspace-layout.md`, "Plugin configuration"). If it is
  missing, ask once where GPU jobs should run and write it.

## Steps

1. **Pick the app.** Use `training_compute.app` (its repo is `training_compute.app_path`;
   read that repo's README before the first run in a session — it has the exact flags,
   storage paths and GPU options). Exception: a project listed in
   `training_compute.dedicated_apps` keeps using its own app, because its pipeline lives
   there. Never move a dedicated project's jobs into the general app, or the reverse.
2. **Check the job is ready.** The eval plan's pass bar and no-model baseline exist
   (`docs/eval-plan.md`), the dataset revision is pinned, and the script writes its
   outputs (checkpoints, metrics, a `result.json`) to the app's run-output location, not
   to the container's ephemeral disk.
3. **Climb the run ladder** (below). On a new script, the first rung is a smoke run on the
   cheapest GPU. Until a probe run shows the approach working, every run is a probe.
4. **Launch.** Smallest GPU that fits the model and batch size. Detach anything longer
   than a few minutes so it survives the session ending. Put any profile/workspace
   selector from `training_compute` on every command.
5. **Record.** When the run finishes, fetch its outputs into the model repo (or record
   where they are), and write the run name, GPU, duration, cost if known and headline
   metric into the project's run log (`project.json` or the repo's own checkpoint
   registry). Update the hub registry status to `training` on the first run.

## The run ladder: probe small, scale on evidence

Early in a project the question is *which approach works*, not *how good can it get*.
Answer it with runs of minutes, not hours. Daniel set this rule on 2026-10-21 after a
52-minute first full run of Proximate-Pseudonymizer only showed the approach was wrong
(a quarter of the identifying details leaked). A 64-row smoke run of the next idea had
already shown its signal in two minutes.

| Rung | Size | Answers | Typical cost |
| --- | --- | --- | --- |
| 1. Smoke | ~50 rows, a few steps, ~16 eval rows | Does the pipeline run end to end and write outputs? | cents, ~2 min |
| 2. Probe | a few hundred to ~1k rows, 1 epoch, a **fixed** eval subset (~100 rows) | Is this approach moving toward the pass bar? | < $0.50, ~5 min |
| 3. Confirm | full data, 1 epoch, full eval | Does the probe's signal hold at full size? | one short run |
| 4. Full | full data, the real epochs/LR, full eval | The number that goes in the release | only after 3 |

Rules:

- **Compare ideas at probe size.** Base models, output formats, learning rates: run them as
  probes on the same subset and the same eval rows, changing one thing at a time. Never fan
  out several full-size runs to explore.
- **Climb only on evidence.** Go up a rung when the metric that decides the pass bar
  clearly moves the right way. If it doesn't move, change the approach (data, output
  shape, base model), not the run length.
- **Kill a run that has answered its question.** Don't let a long run finish just because
  it's already started.
- **Make the training script ladder-ready before the first run.** It needs knobs for
  training rows, eval rows, epochs and LR, plus a skip for the no-model baseline. Compute
  that baseline once and reuse it across runs, since it never changes.
- **Report each probe as a go/no-go against the pass bar,** with its cost, before the next
  launch. Don't present probe numbers as final.
- The run log (`project.json`) records the rung of every run.

## Don'ts

- Don't launch a full-length run (or several) to find out whether an approach works.
  That's what probes are for.
- Don't train on the user's laptop beyond toy runs; check `compute_notes`.
- Don't create a new cloud app for a one-off job. If a project grows a repeated
  multi-stage pipeline (prepare → train → export → publish), propose giving it a
  dedicated app and adding it to `training_compute.dedicated_apps`.
- Don't publish anything to the Hub from a training run without an explicit request. When the
  round is done, `finish-training-run` publishes, archives and clears the storage.
