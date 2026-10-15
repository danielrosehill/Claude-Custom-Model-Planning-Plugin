---
name: start-model-project
description: Create the project repo for a custom model or fine-tune idea (private by default; a public lifecycle repo when the model will be released publicly), seed its docs and project.json, and register it in the hub.
---

# Start a model project

Turns an idea into a **planning repository**: the repo where the fine-tune or
custom model is researched and specified. It is private by default. When the model
is meant to be released publicly on the Hugging Face Hub, the project also gets a
**public GitHub repo that tracks the whole lifecycle** (see *Release intent*). Run it when an idea has
survived a first look, or straight away if the user already knows they want a repo.

Plugin references live at `../../references/` relative to this skill's directory.
Read `workspace-layout.md`. It defines the layout, `project.json` and the hub registry.

## Inputs

- The idea: an existing idea note, `docs/idea.md`, or the user's description.
- Optionally: project name, visibility, release intent, and where to put it.

## Steps

1. **Config.** Read `${WORKSPACE:custom-model-planning}/config.json`, which resolves to
   `${CLAUDE_USER_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/claude-plugins}/custom-model-planning/config.json`.
   If it is missing, ask once for `default_project_dir`, `github_owner`, `hf_owner`,
   optional `hub_path` and `compute_notes`, then write it. `default_visibility`
   defaults to `private`.
2. **Hub conventions.** If `hub_path` is set, read its `CLAUDE.md`/README. Rules
   there override this skill's defaults, for example where repos are filed or
   naming patterns.
3. **Name.** Propose a Train-Case repo name describing the model at maximum
   specificity (`Voice-Note-Intent-Classifier`, not `My-Model`). Confirm it with the
   user only if it is ambiguous.
4. **Release intent.** Ask once, unless the idea note already says: *will the
   model (or its dataset) be published publicly on the Hub?* Record the answer in
   `project.json` → `release` (schema in `workspace-layout.md`).
   - `private` or `undecided`: one private repo, as below.
   - `public`: the project gets a public GitHub repo that tracks the lifecycle end
     to end (idea, prior art, spec, data, training, evaluation, and links to every
     Hub model, dataset and Space), next to the Hub artifacts themselves. Choose the
     shape:
     - **single public repo** (default): the project repo itself is created public.
       Use it when nothing in the plan is private.
     - **private working repo + public tracker**: use it when the working repo will
       hold material that must not be public, such as personal recordings, raw
       private data or unpublished experiments. The tracker is named
       `<Project-Name>` with the working repo as `<Project-Name>-Working`, unless
       the hub's conventions name them differently. The tracker holds the README,
       the public docs (idea, prior-art, spec, eval results, model card) and the
       Hub links. It never holds raw data.
   The user saying the model will be public is the request for the public repo.
   State the repo name and visibility once before creating it.
5. **Pre-flight.** Check that the local directory does not exist and that
   `gh repo view <owner>/<name>` fails. If either exists, stop and ask. Never overwrite.
6. **Scaffold** only what has content now:
   - `README.md`: one-paragraph purpose, `Status: planning, <date>`, a
     read-in-this-order table listing only files that exist, and a line saying this
     repo was started with the `custom-model-planning` plugin. For a public
     release, add a **Fit and adaptation** section: whose use case the model and
     data were built around (languages, domain, a single speaker or user), how
     that limits its usefulness to others, and how to adapt it (swap or extend
     the dataset, fine-tune further from the published checkpoint).
   - `docs/idea.md`: move the hub idea note here, or write it fresh with the user's
     words verbatim first. In the hub, replace the idea note with a one-line pointer
     to the new repo.
   - `project.json` per the schema, with `status: "planning"`. Carry over
     `exists_check` results and research files if they already exist.
   - `.gitignore` covering `.venv/`, `__pycache__/`, `*.safetensors`, `*.bin`,
     `*.gguf`, `wandb/`, `outputs/`, `checkpoints/` and `data/raw/`.
7. **Git.** Run `git init`, commit, then
   `gh repo create <owner>/<name> --private --source=. --push` (`--public` for a
   single public repo, per step 4). Record the URL in `project.json` →
   `links.github`. For the working + tracker shape, create the tracker with the same
   files minus anything private, push it `--public`, and record it in
   `links.public_repo`. Both repos' READMEs link to each other (the tracker's link
   says the working repo is private).
8. **Registry.** If a hub registry exists, add or update this project's entry
   (`status: "planning"`, `status_date`, `local_path`, `github`, `visibility`, `task`,
   and `public_repo` when there is a separate tracker). Commit and push the hub.
9. **Next step.** If no exists check has been run, run `model-exists-check` now.
   Otherwise suggest `frame-the-task`.

## Data storage

Writes `${WORKSPACE:custom-model-planning}/config.json` (pointers only). Creates the
planning repo at the user-chosen path and edits the hub. Nothing is stored under
the plugin install directory.

## Notes

- Creating a GitHub repo is an outward action. Private is the default. A public
  repo is created only when the user asked for one or said the model will be
  released publicly (step 4).
- Keeping a public tracker current is part of the project, not an afterthought:
  whenever a later stage publishes a Hub model, dataset or Space, or produces
  evaluation numbers, update the public repo's README and links in the same session.
- Do not create a Hugging Face repo here. The Hub comes much later, when there is
  something to publish.
