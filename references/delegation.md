# What this plugin does not do, and who does

This plugin ends at a **specification**. Building, training, labelling and evaluating
are other tools' jobs. When a stage needs one of them, check whether it is installed
(it appears in the session's skill list). If it is, hand off. If not, fall back as
listed and name the plugin so the user can install it.

## Official Hugging Face skills

Marketplace: `huggingface/skills` (`/plugin marketplace add huggingface/skills`).
Skill names as of 2026-10-15:

| Need | Skill | Fallback if absent |
| --- | --- | --- |
| Hub search, downloads, repo creation, Jobs | `hf-cli` | `hf` CLI directly, or the REST recipes in `hub-search-recipes.md` |
| Paper search and reading | `huggingface-papers` | `GET /api/papers/search?q=`, `hf papers read <id>` |
| Dataset inspection | `huggingface-datasets` | dataset viewer API: `https://datasets-server.huggingface.co/first-rows?dataset=<id>&config=default&split=train` |
| Fine-tuning LLMs (SFT/DPO/GRPO) | `huggingface-llm-trainer`, `trl-training` | Write the training recipe into the spec only |
| Sentence-transformers / embedding training | `train-sentence-transformers` | Same |
| Vision fine-tuning | `huggingface-vision-trainer` | Same |
| Running community evals | `huggingface-community-evals` | `eval-runner` (below) or lighteval docs |
| Will it fit in memory? | `hf-mem` | params × bytes-per-param × ~1.2 overhead, stated as an estimate |
| Browser / on-device inference | `transformers-js` | — |

## Other plugins in the same marketplace as this one

| Need | Plugin |
| --- | --- |
| Designing a label schema and annotating data | `data-annotation` |
| Generating synthetic training data | `synthetic-data` |
| Cleaning and packaging datasets, pushing to the Hub | `Claude-Data-Wrangler` |
| Building and running eval suites | `eval-runner` |
| Choosing a **hosted** LLM to call (rung 2 of the ladder) | `ai-model-research` (OpenRouter catalogue) |

## Boundaries

- **No training runs.** Even if a trainer skill is installed, do not start a paid
  Job or a long GPU run from a planning skill. The spec says what to run, and
  the user starts it.
- **No Hub writes** without an explicit request. Creating a model or dataset repo
  is publishing.
- **No GitHub repo creation** beyond the planning repo itself, which
  `start-model-project` creates private unless told otherwise.
