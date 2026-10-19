# Planning workspace layout

Every model idea that gets past a quick look gets its **own planning repository**.
Optionally, a single **hub repository** sits above them: a place to jot down ideas
before they earn a repo, and a registry tying all model projects together.

The repo is the handover. An agent opening it cold, months later, must be able to
tell what the idea is, what was found, what was decided and why, and what happens
next. It should not need this plugin, a chat history or the user's memory.

Repos are **private by default**. Ideas are often half-formed or commercially
sensitive. When a model is going to be released publicly on the Hub, the project
also gets a **public GitHub repo tracking the whole lifecycle** alongside the Hub
model and dataset: either the project repo itself is public, or a private working
repo is paired with a public tracker repo when the working repo holds private
material. `start-model-project` makes that choice and records it in
`project.json` → `release`.

## The optional hub

```
<hub>/                        # e.g. AI-Model-Development-Workspace
├── README.md
├── ideas/<slug>.md           # one file per idea not yet spun out (capture-model-idea)
├── research/<slug>/…         # exists-check results for ideas still in the hub
└── projects.json             # registry of every model project
```

`projects.json` is a pointer, not the source of truth. Re-verify a status against the
project's README and the Hub before quoting it.

```json
{
  "updated": "2026-10-15",
  "projects": [
    {
      "name": "Example-Intent-Classifier",
      "local_path": "ai-models/Example-Intent-Classifier",
      "github": "owner/Example-Intent-Classifier",
      "visibility": "private",
      "task": "Sequence classification: route voice-note transcripts to one of 6 handlers",
      "base_model": null,
      "status": "planning",
      "status_date": "2026-10-15",
      "hf": {"models": [], "datasets": [], "spaces": []},
      "public_repo": null,
      "notes": ""
    }
  ]
}
```

`status`: `idea` · `planning` · `data` · `training` · `released` · `shelved`.
`local_path` is relative to the user's repos root. Preserve any extra fields an
existing registry already has, and never rewrite other projects' entries.

Without a hub, ideas go straight into a planning repo and there is no registry.

## The per-model planning repo

```
<Project-Name>/
├── README.md                 # what this is, status line, read-in-this-order table
├── project.json              # machine-readable state, see below
└── docs/
    ├── idea.md               # the idea: user's words verbatim first, then restated
    ├── requirements.md       # task framing: I/O contract, constraints, success metric (frame-the-task)
    ├── prior-art.md          # what exists: models, datasets, papers, Spaces, repos (survey-prior-art)
    ├── options.md            # approaches compared on the ladder (compare-approaches)
    ├── base-model.md         # base-model shortlist and choice (select-base-model)
    ├── data-plan.md          # training/eval data: sources, labelling, splits (plan-training-data)
    ├── eval-plan.md          # metrics, eval set, baselines, pass bar (plan-evaluation)
    ├── spec.md               # the specification (write-model-spec)
    ├── model-card-draft.md   # draft Hub model card (write-model-spec)
    ├── decisions/NNNN-<slug>.md
    └── research/YYYY-MM-DD-<source>.md   # raw findings, one file per search pass
```

Create a file or folder when the first thing goes in it. Never scaffold empty
placeholders. An empty `data-plan.md` reads as "data was considered" when it was not.

The same repo later holds the build (training code, data scripts, eval results), or
the spec points at a separate implementation repo. Either is fine. Record which in
`project.json` → `links.implementation_repo`.

## `project.json`

The status skill and every stage skill read and update this file. Keep it valid JSON.
Update `updated` and the relevant stage on every write. When a hub exists, mirror
`status` into the hub registry entry.

```json
{
  "schema": 1,
  "name": "example-intent-classifier",
  "title": "Route voice-note transcripts to the right handler",
  "created": "2026-10-15",
  "updated": "2026-10-15",
  "status": "planning",
  "stage": "framing",
  "verdict": null,
  "task": {
    "pipeline_tag": "text-classification",
    "modality": "text",
    "languages": ["en"],
    "deployment": "cpu-server",
    "size_budget_params": 150000000
  },
  "stages": {
    "exists_check": {"status": "done",        "date": "2026-10-15", "result": "partial"},
    "framing":      {"status": "in_progress", "date": null},
    "prior_art":    {"status": "todo",        "date": null},
    "approaches":   {"status": "todo",        "date": null},
    "base_model":   {"status": "todo",        "date": null},
    "data":         {"status": "todo",        "date": null},
    "evaluation":   {"status": "todo",        "date": null},
    "spec":         {"status": "todo",        "date": null}
  },
  "links": {
    "github": null,
    "hub_entry": null,
    "hf_models": [],
    "hf_datasets": [],
    "implementation_repo": null,
    "public_repo": null
  },
  "release": {
    "intent": "private",
    "shape": null
  }
}
```

- `status` matches the hub registry vocabulary. `stage` is the current key in `stages`.
- `stages.*.status` takes `todo` | `in_progress` | `done` | `skipped`. A skipped stage
  gets a reason in `docs/decisions/`, not a `todo` left forever.
- `verdict` is set by `compare-approaches`: `use-existing` | `no-model` |
  `prompt-an-llm` | `fine-tune` | `distill` | `train-from-scratch` | `abandon`.
- `exists_check.result` takes `exists` | `partial` | `none`.
- `release.intent` takes `private` | `public` | `undecided`. `release.shape` is
  `null` unless `intent` is `public`, then `single-public-repo` |
  `working-plus-tracker`. `links.public_repo` is set only for `working-plus-tracker`;
  for a single public repo, `links.github` is already the public repo.
- `project.json` files written before `release` existed are read as
  `{"intent": "undecided"}`.

## Writing rules

- **Absolute dates.** Write "as of 2026-10-15", never "currently" or "recently".
  Hub download counts and leaderboards move weekly.
- **Confirmed vs inferred.** Mark what you checked (opened the card, ran the query)
  separately from what you inferred (from a name, a tag, a summary). A model tagged
  `he` may still handle Hebrew badly.
- **Links, not prose.** Cite every model, dataset and paper by Hub ID or URL.
- **Record wrong turns.** Put empty queries and ruled-out candidates, with the reason,
  in `docs/research/` so nobody re-runs them.
- **Decisions get a file.** Each one goes in `docs/decisions/NNNN-<slug>.md`: context,
  options, choice, the constraint that settled it, and the date.

## Plugin configuration

The plugin stores only pointers, never the repos themselves:

`${WORKSPACE:custom-model-planning}/config.json` resolves to
`${CLAUDE_USER_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/claude-plugins}/custom-model-planning/config.json`

```json
{
  "repos_root": "~/repos",
  "default_project_dir": "~/repos/ai-models",
  "hub_path": "~/repos/ai-models/AI-Model-Development-Workspace",
  "github_owner": "<user-or-org>",
  "default_visibility": "private",
  "hf_owner": "<hf-user-or-org>",
  "compute_notes": "CPU-only laptop; GPU training on a rented cloud GPU",
  "training_compute": {
    "provider": "modal",
    "app": "ai-training",
    "app_path": "~/repos/ai-models/Modal-AI-Training",
    "env": "MODAL_PROFILE=<workspace>",
    "dedicated_apps": {"<project-name>": "<its own app>"}
  }
}
```

`training_compute` is where `run-training-job` sends GPU jobs: one general-purpose app,
plus any projects that keep a dedicated app of their own.

`hub_path`, `compute_notes` and `training_compute` are optional. The first skill that needs a missing
value asks for it once and writes it. If the hub has its own `CLAUDE.md` or README
conventions (naming, where repos are filed, HF orgs), **those win** over this file.
