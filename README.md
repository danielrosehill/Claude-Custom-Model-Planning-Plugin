# Custom Model Planning

A Claude Code plugin for developers planning **niche open-source models**: small,
task-bounded models, classifiers and fine-tunes. It covers the planning half of the
lifecycle:

> *Is there already a model that does this? Could I build one? Should I fine-tune,
> distil, prompt an LLM, or not use a model at all? And if I build it, what exactly?*

It checks what the Hugging Face Hub already offers, records the idea in a private
planning repository, researches the options, writes the findings up, and ends with
a specification someone can build from. It does not train anything. Training,
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
| `start-model-project` | Create a **private** planning repo, seed `project.json`, register it in the hub | new repo |
| `frame-the-task` | Turn the idea into an ML task: formulation, I/O contract, labels, constraints, success metric | `docs/requirements.md` |
| `survey-prior-art` | Deep research across Hub models, datasets, papers, Spaces and GitHub, with parallel scouts | `docs/prior-art.md`, `docs/research/` |
| `compare-approaches` | Walk the approach ladder from no model up to training from scratch, and record a verdict | `docs/options.md`, `docs/decisions/` |
| `select-base-model` | Shortlist small bases by size, licence, tokenizer coverage and task fit | `docs/base-model.md` |
| `plan-training-data` | Sources, labelling, synthetic data, volumes, leakage-safe splits, licence chain | `docs/data-plan.md` |
| `plan-evaluation` | Metrics, a mandatory no-model baseline, a pass bar fixed before training | `docs/eval-plan.md` |
| `write-model-spec` | The build spec plus a draft Hub model card | `docs/spec.md`, `docs/model-card-draft.md` |
| `model-project-status` | Stage, verdict and next step for one project, or every project in the hub | — |

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
- **Private by default.** Planning repos are created private, and nothing is
  published to the Hub without an explicit request.

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
- **Same marketplace:** `data-annotation`, `synthetic-data`, `Claude-Data-Wrangler`,
  `eval-runner`, and `ai-model-research` (for choosing a hosted LLM when the verdict
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
