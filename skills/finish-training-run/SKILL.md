---
name: finish-training-run
description: Close out a model project's training runs once they are done — pick the run to release, publish it to Hugging Face with a model card, archive its weights for safekeeping, verify both copies, then delete every weight, checkpoint and leftover the project's runs left on the training compute's storage (e.g. the Modal `ai-training` volume) so it stops accruing storage charges. Use when the user says "we're done, push it to Hugging Face", "publish the best run", "clean up Modal", "get rid of the checkpoints", or right after `run-training-job` finishes the last run of a round.
---

# Finish a training round: publish, archive, clean up

`run-training-job` ends with runs sitting on the training compute's storage. Each run of a
small model leaves its model weights plus `ckpt/` (trainer checkpoints) behind, and nothing
removes them. This skill is the other end: one run goes to the Hub, its weights go to the
archive, and the storage holds only the small files the docs cite.

Order matters. **Nothing is deleted until the published copy and the archived copy have both
been checked.** Hugging Face is a publishing channel, not a backup (a published repo has been
found deleted before: see `parakeet-finetune-ops:wasabi-archive`).

## Inputs

- The project's runs for this round, from its run log (`docs/training.md`, `project.json` or
  `runs/`). Only those runs. The storage is shared: never touch another project's run, the
  shared caches (`hf/`, `uv-cache/` on the `ai-training` volume) or a run that is still going.
- Config `training_compute` (app, volume, profile). For Daniel: Modal app `ai-training`, volume
  `ai-training`, `MODAL_PROFILE=danielrosehill`, runs at `runs/<run>/`.
- Hub visibility: what the user said, else the project's `visibility` in `project.json`,
  else **private**. Making a model public is publishing; get a yes for it.

## Steps

1. **Confirm the round is finished.** Every run of the round has its `metrics.json` (or
   `result.json`). Don't clean up around a run that is still training.
2. **Pick the run.** The best held-out headline metric; on a tie, the cheaper/shorter run.
   Say which and why in one line. Fetch every run's small files (`metrics.json`,
   `pred_*.jsonl`) into the repo's `runs/<run>/` first; they are what the docs cite.
   `modal volume get <vol> runs/<run>/<file> runs/<run>/<file>`: give the full destination
   path. A bare directory destination that does not exist yet is written as a file.
3. **Publish.** Download the run's `model/` and upload it with a model card (`README.md`) that
   states: the task, base model, training data (gold vs silver/LLM-labelled counts), the
   held-out metric and its size, how outputs are validated, limitations, and the run name.
   `hf repo create <user>/<Name> --repo-type model [--private]`, then `hf upload`. Upload each file
   over ~1 GB in its own `hf upload` call (a whole-folder upload was killed by memory pressure
   while hashing a 1.7 GB file, 2026-10-21). Check: list the repo's files and compare each
   LFS `sha256` (`HfApi().model_info(repo, files_metadata=True)`) with the local file.
4. **Archive.** Daniel's procedure is `parakeet-finetune-ops:wasabi-archive` section 6
   (bucket `small-models`, `rclone check` must report 0 differences). Archive the published
   run. Archive runs that were not published only if the user asks; their metrics and
   predictions in the repo are the record, and any of them retrains from the same command.
5. **Clean up the storage**, only for this project's runs and only after 3 and 4 checked out:
   delete each run's weights and checkpoints and anything else large; keep `metrics.json`,
   `pred_*.jsonl`, `job.log`.
   ```bash
   export MODAL_PROFILE=danielrosehill
   for run in <run> ...; do
     for d in model ckpt onnx; do modal volume rm -r ai-training runs/$run/$d 2>/dev/null; done
     modal volume ls ai-training runs/$run          # what is left must be small files only
   done
   ```
   Also remove the project's aborted or smoke runs that left weights. Leave the shared
   caches alone unless the user asks: they are re-downloaded by the next run of any project.
6. **Record.** In the project's run log: which run was published (Hub URL, visibility), where
   the archive is, and that the weights are gone from the training storage. Update
   `project.json` (`status`, model link). Then report: published repo, archive path, what was
   deleted, and anything else large you saw on the storage that belongs to another project
   (name it; don't delete it).

## Don'ts

- Don't delete in the same command as the archive or the upload, and never before checking them.
- Don't delete another project's runs or the shared caches because they are "leftovers".
- Don't make a model public without a yes, even if the sibling project's model is public.
