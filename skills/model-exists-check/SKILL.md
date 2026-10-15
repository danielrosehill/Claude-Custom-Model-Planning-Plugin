---
name: model-exists-check
description: Is there already a model that does this? Quick Hugging Face Hub triage of models, fine-tunes, datasets and papers for a task idea.
---

# Does a model for this already exist?

A fast, bounded check, usually 5–15 queries, that answers "is there a model that
does this?" before anyone plans to build one. It works standalone, with no project
needed, and it is also the first stage of a model project.

This is triage, not a survey. If the answer is "partially", `survey-prior-art` does
the deep pass.

Plugin references live at `../../references/` relative to this skill's directory.
**Read `hub-search-recipes.md` first.** Several obvious Hub API filters fail
silently, and getting them wrong produces a false "nothing exists".

## Inputs

- The task in the user's words, or an idea note or `docs/idea.md`.
- Hard constraints if known: language(s), modality, size budget, licence.

## Steps

1. Restate the task as one or two candidate **pipeline tags**
   (`task-taxonomy.md`) plus 3–6 search phrasings: the user's words, the ML term for
   the task, and domain synonyms.
2. Query the Hub using `hf` CLI if installed, else the REST endpoints. Prefer the
   `hf-cli` skill if the session has it.
   - Models: by pipeline tag + each phrasing, sorted by downloads, with `expand`
     for `cardData`, `safetensors`, `lastModified`, `tags`, `pipeline_tag`.
   - Language-constrained: `filter=<iso>` (bare tag), then check `cardData.language`.
   - Fine-tunes of the obvious bases: `filter=base_model:<id>` with the task words.
   - Datasets for the task: a labelled dataset with no model is a finding.
   - Papers: `/api/papers/search?q=`.
   - Spaces: a demo often surfaces a model that is tagged badly.
3. For the top 3–5 candidates, **open the model card**. Confirm the labels or output
   format, training data, language, licence and size (`safetensors.total`, bucketed
   as in the recipes). Do not judge from names or tags alone.
4. Give a verdict:
   - **exists**: a model matches task, labels, language, size and licence. Name it,
     link it, and say what to test it on.
   - **partial**: something close exists (wrong labels, wrong language, too big,
     non-commercial licence, or a dataset but no model). Say exactly what the gap is.
   - **none**: nothing found. List what was searched so the absence is credible.
5. Output a short table of candidates: id, size bucket, licence, last modified,
   downloads, fit, and the gap.
6. If inside a project or hub, write the full query log and results to
   `docs/research/<date>-exists-check.md` (or `<hub>/research/<slug>/`), and set
   `stages.exists_check` with `result` in `project.json`. Otherwise just report.

## Notes

- **An empty result is suspect before it is a finding.** If a reasonable query
  returns zero, re-check the filter syntax against the recipes and try a broader
  phrasing before concluding "none".
- Popularity is not fitness. A high-download model can still fail the user's labels or language.
- Do not recommend building anything here. The verdict feeds `compare-approaches`.
- Network calls: read-only requests to `huggingface.co`. No token needed for public repos.
