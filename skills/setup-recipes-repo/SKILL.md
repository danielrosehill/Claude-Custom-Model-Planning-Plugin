---
name: setup-recipes-repo
description: Create or connect the private GitHub repo that stores training recipes and save its location. Use for "set up my recipes repo".
---

# Set up the training recipes repo

Training recipes live in one private GitHub repo that the user owns, separate from the
plugin, so updates can't touch them and nothing is published.

## Steps

1. Run `../../scripts/paths.sh init`. If `../../scripts/paths.sh override setup-recipes-repo`
   prints a path, read that file and follow it.
2. Read `recipes_repo` from config (see "Plugin configuration" in
   `../../references/workspace-layout.md`). If it is set and the path exists, report it
   and stop unless the user wants to change it.
3. Ask whether a recipes repo already exists.
   - **It exists:** take its local path or `owner/name`. Clone it under `repos_root` if
     it isn't local. Check its visibility with `gh repo view --json visibility`. If it
     is public, say so and ask before using it.
   - **It doesn't:** propose `<github_owner>/Training-Recipes`, then run
     `gh repo create <owner>/<name> --private --clone` from `repos_root`.
4. If the repo is empty, seed it: a README describing the layout below, and a
   `.gitignore` covering `outputs/`, `*.safetensors`, `*.gguf`, `*.bin`, `*.pt`,
   `.env` and `unsloth_env/`. Create `recipes/` and `runs/`. Commit and push.
5. Write `recipes_repo` (`path`, `remote`) to `config.json`, keeping every other key.
6. If the agent has a persistent memory, save the repo's location there as well. Config
   is the source of truth, and memory is what lets other sessions find it.

## Repo layout

```
<recipes repo>/
├── recipes/<slug>/    # recipe.yaml, train.py, requirements.txt, README.md
└── runs/              # one <YYYY-MM-DD>_<recipe>_<rung>.json per run
```

## Data storage

Writes only `recipes_repo` in `${WORKSPACE:custom-model-planning}/config.json`, plus the
recipes repo itself.

## Notes

Weights and datasets don't belong in this repo: it holds recipes and run records.
Creating the repo and pushing are network actions on the user's GitHub account.
