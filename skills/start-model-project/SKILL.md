---
name: start-model-project
description: Create a private planning repo for a custom model or fine-tune idea, seed its docs and project.json, and register it in the hub.
---

# Start a model project

Turns an idea into a **planning repository**: the private repo where the
fine-tune or custom model is researched and specified. Run it when an idea has
survived a first look, or straight away if the user already knows they want a repo.

Plugin references live at `../../references/` relative to this skill's directory.
Read `workspace-layout.md`. It defines the layout, `project.json` and the hub registry.

## Inputs

- The idea: an existing idea note, `docs/idea.md`, or the user's description.
- Optionally: project name, visibility, and where to put it.

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
4. **Pre-flight.** Check that the local directory does not exist and that
   `gh repo view <owner>/<name>` fails. If either exists, stop and ask. Never overwrite.
5. **Scaffold** only what has content now:
   - `README.md`: one-paragraph purpose, `Status: planning, <date>`, a
     read-in-this-order table listing only files that exist, and a line saying this
     repo was started with the `custom-model-planning` plugin.
   - `docs/idea.md`: move the hub idea note here, or write it fresh with the user's
     words verbatim first. In the hub, replace the idea note with a one-line pointer
     to the new repo.
   - `project.json` per the schema, with `status: "planning"`. Carry over
     `exists_check` results and research files if they already exist.
   - `.gitignore` covering `.venv/`, `__pycache__/`, `*.safetensors`, `*.bin`,
     `*.gguf`, `wandb/`, `outputs/`, `checkpoints/` and `data/raw/`.
6. **Git.** Run `git init`, commit, then
   `gh repo create <owner>/<name> --private --source=. --push` (`--public` only if the
   user asked). Record the URL in `project.json` → `links.github`.
7. **Registry.** If a hub registry exists, add or update this project's entry
   (`status: "planning"`, `status_date`, `local_path`, `github`, `visibility`, `task`).
   Commit and push the hub.
8. **Next step.** If no exists check has been run, run `model-exists-check` now.
   Otherwise suggest `frame-the-task`.

## Data storage

Writes `${WORKSPACE:custom-model-planning}/config.json` (pointers only). Creates the
planning repo at the user-chosen path and edits the hub. Nothing is stored under
the plugin install directory.

## Notes

- Creating a GitHub repo is an outward action. Private is the default, and a public
  repo is created only on explicit request.
- Do not create a Hugging Face repo here. The Hub comes much later, when there is
  something to publish.
