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
3. **Smoke first.** On a new script, run it once on the cheapest GPU with a tiny
   step/epoch count. A failed smoke run costs cents; a failed long run does not.
4. **Launch.** Smallest GPU that fits the model and batch size. Detach anything longer
   than a few minutes so it survives the session ending. Put any profile/workspace
   selector from `training_compute` on every command.
5. **Record.** When the run finishes, fetch its outputs into the model repo (or record
   where they are), and write the run name, GPU, duration, cost if known and headline
   metric into the project's run log (`project.json` or the repo's own checkpoint
   registry). Update the hub registry status to `training` on the first run.

## Don'ts

- Don't train on the user's laptop beyond toy runs; check `compute_notes`.
- Don't create a new cloud app for a one-off job. If a project grows a repeated
  multi-stage pipeline (prepare → train → export → publish), propose giving it a
  dedicated app and adding it to `training_compute.dedicated_apps`.
- Don't publish anything to the Hub from a training run without an explicit request.
