---
name: create-training-run
description: Create and launch a training run from a saved recipe on Modal, RunPod or local Unsloth. Use for "train with this recipe", "new recipe".
---

# Create a training run from a recipe

A run is one recipe on one backend at one rung of the run ladder. For a model project
with a spec and eval plan, use `run-training-job`, which routes to the designated
training compute. This skill is for recipes that stand on their own.

## Inputs

- A recipe slug, or a description of a new one.
- A backend: the recipe's `backend`, or the user's choice.
- A rung: smoke, unless the user names another.

## Steps

1. If `../../scripts/paths.sh override create-training-run` prints a path, read that file
   and follow it.
2. Read `recipes_repo` from config. If it is missing, run `setup-recipes-repo` first.
   Pull the repo.
3. **Pick the recipe.** List `recipes/`. For a new recipe, copy the folder printed by
   `../../scripts/paths.sh template` to `recipes/<slug>/` and fill in `recipe.yaml` and
   `train.py` with the user. Every placeholder must be gone before a launch.
4. **Pick the backend.** `../../scripts/paths.sh backends` lists them. Read the file from
   `../../scripts/paths.sh backend <name>` and follow it for the launch, watch, stop and
   teardown steps. If the backend isn't set up, run `setup-cloud-training` or
   `setup-unsloth-local`.
5. **Pick the rung.** Follow the run ladder in `../run-training-job/SKILL.md`: smoke
   first on a new recipe, climbing only on evidence. Take sizes from `ladder` in
   `recipe.yaml`.
6. **Confirm any paid launch.** State the backend, GPU, rung, expected duration and
   estimated cost, and get a yes. Don't launch on a guess at the price.
7. **Launch** as the backend file says, detached if it will take more than a few minutes.
8. **Record** `runs/<YYYY-MM-DD>_<recipe>_<rung>.json` in the recipes repo: recipe, git
   commit, backend, GPU, rung, duration, cost if known, headline metric, where the
   outputs are, and status. Commit and push.
9. **Tear down.** Confirm nothing is still billing, using the backend file's check.

## Data storage

Writes recipes and run records to the recipes repo only. Weights stay on the backend or
in `outputs/`, which git ignores.

## Notes

Launching a cloud run spends the user's money. An override can't remove step 6.
`finish-training-run` publishes and archives a finished run.
