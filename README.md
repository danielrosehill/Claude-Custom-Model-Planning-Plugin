# Custom Model Planning

A Claude Code plugin for developers planning **niche open-source models**: small,
task-bounded models, classifiers and fine-tunes. It covers the planning half of the
lifecycle:

> *Is there already a model that does this? Could I build one? Should I fine-tune,
> distil, prompt an LLM, or not use a model at all? And if I build it, what exactly?*

It checks what the Hugging Face Hub already offers, records the idea in a private
planning repository, researches the options, writes the findings up, and ends with
a specification someone can build from. `run-training-job` routes planned jobs to your
designated training compute, `create-training-run` runs saved recipes from your private
recipes repo on Modal, RunPod or local Unsloth, and `finish-training-run` publishes the
result and clears the training storage afterwards. Training,
labelling and evaluation hand off to the official Hugging Face skills and other
plugins when they are installed.

## The lifecycle

```
capture-model-idea ─► model-exists-check ─► start-model-project ─► frame-the-task
        │                    │ (exists → stop, use it)
        ▼                    ▼
  survey-prior-art ─► compare-approaches ─► select-base-model ─► plan-training-data
                            │ (no-model / LLM / existing → skip to eval)
                            ▼
                     plan-evaluation ─► write-model-spec
```

`model-project-status` tells you where any project is and what to run next.

## Skills

| Skill | What it does | Writes |
| --- | --- | --- |
| `capture-model-idea` | Write down a model idea before deciding whether it earns a repo | `ideas/<slug>.md` in the hub, or `docs/idea.md` |
| `model-exists-check` | Quick Hub triage: is there already a model, fine-tune or dataset for this? Verdict: exists / partial / none | `docs/research/` |
| `start-model-project` | Create the planning repo (**private** by default; plus a public lifecycle repo when the model will be public), seed `project.json`, register it in the hub | new repo(s) |
| `frame-the-task` | Turn the idea into an ML task: formulation, I/O contract, labels, constraints, success metric | `docs/requirements.md` |
| `survey-prior-art` | Deep research across Hub models, datasets, papers, Spaces and GitHub, with parallel scouts | `docs/prior-art.md`, `docs/research/` |
| `compare-approaches` | Walk the approach ladder from no model up to training from scratch, and record a verdict | `docs/options.md`, `docs/decisions/` |
| `select-base-model` | Shortlist small bases by size, licence, tokenizer coverage and task fit | `docs/base-model.md` |
| `plan-training-data` | Sources, labelling, synthetic data, volumes, leakage-safe splits, licence chain | `docs/data-plan.md` |
| `plan-evaluation` | Metrics, a mandatory no-model baseline, a pass bar fixed before training | `docs/eval-plan.md` |
| `write-model-spec` | The build spec plus a draft Hub model card | `docs/spec.md`, `docs/model-card-draft.md` |
| `evaluate-incremental-training` | Before retraining: can the model continue from its last checkpoint? Measures the delta and checks tokenizer, labels, format, splits and distribution against the parent run. Verdict: incremental / after a fix / from scratch / keep building | JSON beside the run records |
| `standardize-dataset` | Before a from-scratch run: inventory the conventions across every constituent dataset, write one standard, dry-run the rewrite and enforce it at ingest | standard doc, decisions file, rewritten labels (on your yes) |
| `model-project-status` | Stage, verdict and next step for one project, or every project in the hub | — |
| `dataset-map` | The hub's map of shared datasets: one canonical corpus, its views, and which projects consume each; reuse before collecting again | `datasets.json` in the hub |
| `run-training-job` | Run training/fine-tune/eval jobs on the one designated training app (config `training_compute`), climbing a run ladder: smoke → probe → confirm → full, scaling only on evidence | run log in the project |
| `finish-training-run` | Close out a round: publish the best run to the Hub, archive its weights, verify both, then delete the round's weights and checkpoints from the training storage so it stops costing money | Hub repo, run log |

### Training recipes and backends

| Skill | What it does | Writes |
| --- | --- | --- |
| `setup-recipes-repo` | Create or connect your private GitHub repo for training recipes and save its location | recipes repo, config `recipes_repo` |
| `create-training-run` | Create a recipe, or launch a saved one on a chosen backend, starting at the smoke rung and confirming any paid launch | `runs/` in the recipes repo |
| `setup-cloud-training` | Install and authenticate the Modal and RunPod CLIs | config `training_backends` |
| `setup-unsloth-local` | Check for an NVIDIA GPU, then install Unsloth for on-device fine-tuning | config `training_backends` |

These ship as a starting shell. Customise them in your user overlay, which plugin updates
never touch: `scripts/paths.sh init` creates it and seeds a placeholder for each skill in
`overrides/`, and you can add your own backends and recipe template. See
[workspace-layout.md](references/workspace-layout.md#user-overlay).

### Agent

- `prior-art-scout` searches one source class (Hub models, Hub datasets, papers, or
  code and demos) and returns structured JSON findings. `survey-prior-art` runs four
  of them in parallel.

## Design principles

- **The cheapest rung that works wins.** The [approach ladder](references/approach-ladder.md)
  starts at "no model". Ending the project with "this model already exists" or "a
  regex does it" is a successful outcome.
- **A no-model baseline is always defined**, and the model has to beat it.
- **Verify, don't trust tags.** Every candidate's card is opened. Several Hub API
  filters fail silently. See [hub-search-recipes.md](references/hub-search-recipes.md).
- **The repo is the handover.** Dated findings, confirmed vs inferred claims, a
  machine-readable `project.json`, and a decision file per choice. See
  [workspace-layout.md](references/workspace-layout.md).
- **Private by default, public when the model is.** Planning repos are created
  private, and nothing is published to the Hub without an explicit request. A model
  headed for public release gets a public GitHub repo tracking its whole lifecycle
  next to the Hub model and dataset, and its card says plainly whose use case it
  was built for and how to adapt it.

## Optional hub

If you plan several models, point the plugin at a **hub repo**: one place for raw
ideas (`ideas/`) and a registry of every model project (`projects.json`), with each
project in its own repo filed wherever you like. The hub's own `CLAUDE.md`
conventions override the plugin's defaults.

## Works with

The plugin degrades gracefully without these and uses the `hf` CLI or REST API directly.

- **Official Hugging Face skills** (`/plugin marketplace add huggingface/skills`):
  `hf-cli`, `huggingface-papers`, `huggingface-datasets`, `hf-mem`, and the trainer
  skills for the build phase.
- **Same marketplace:** `data-annotation`, `synthetic-data`, `data-wrangler`,
  `ai-eval`, and `ai-model-research` (for choosing a hosted LLM when the verdict
  is "prompt an LLM").

See [delegation.md](references/delegation.md).

## Configuration

The first skill that needs it asks for a few values (project directory, GitHub owner,
HF owner, optional hub path) and stores them at:

```
${CLAUDE_USER_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/claude-plugins}/custom-model-planning/config.json
```

Only pointers live there. Your planning repos live wherever you choose.

## Installation

In Claude Code 2.1.275 or later, one step:

```
/plugin install custom-model-planning --marketplace danielrosehill/Claude-Code-Plugins
```

Or add the marketplace first:

```bash
claude plugins marketplace add danielrosehill/Claude-Code-Plugins
claude plugins install custom-model-planning@danielrosehill
```

Requires `git` and `gh` (for creating planning repos). The `hf` CLI is recommended.
No Hugging Face token is needed for searching public models.

## License

MIT
