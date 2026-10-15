---
name: survey-prior-art
description: Deep prior-art research for a model idea: Hub models, fine-tunes, datasets, papers, Spaces and GitHub, written up as research findings.
---

# Survey prior art

The thorough pass after framing. It answers what exists for this task, how well it
works, what data exists, and what the published results say is achievable at small
sizes. The output is evidence that later stages cite. Do not decide here.

Plugin references live at `../../references/` relative to this skill's directory.
Read `hub-search-recipes.md` (the filter traps matter) and `delegation.md`.

## Inputs

- `docs/requirements.md` (the framed task) and the exists-check research.

## Steps

1. Build a **search plan**: pipeline tag(s), 5–10 phrasings including domain
   synonyms, the relevant languages, and the likely base families from
   `task-taxonomy.md`. Write it at the top of the research file.
2. **Fan out.** Launch the `prior-art-scout` agent once per source class, in
   parallel, each with the framed task and search plan:
   - `hub-models`: task models and fine-tunes of likely bases.
   - `hub-datasets`: labelled data for the task, language and domain.
   - `papers`: Hub papers search + arXiv. What results exist at small sizes?
   - `code-and-demos`: Spaces, GitHub repos, blog posts with reproducible recipes.
   If agents are unavailable, run the same four passes in sequence.
3. **Verify what comes back.** Scouts can be confidently wrong. For every candidate
   that would change a decision, open the card or paper yourself. Confirm labels,
   language, size, licence and the reported numbers with their eval set.
4. Write `docs/research/<date>-prior-art-<source>.md` per source: raw results,
   queries run, result counts, empty queries, and why candidates were ruled out.
5. Write or update `docs/prior-art.md`, the synthesis:
   - **Bottom line** in 3–5 bullets: what exists, the closest thing, the gap.
   - **Models** table: id, size, licence, task/labels, language, reported metric (on
     what), fit, gap, confirmed/inferred.
   - **Datasets** table: id, size, labels, language, licence, quality notes.
   - **Published results**: what accuracy is achievable at what size, with citations.
   - **Recipes worth copying**: training setups from papers and repos.
   - **Searched and found nothing**: the queries, so absence is credible.
   - `As of <date>`.
6. Update `project.json` (`stages.prior_art`, `stage`). Commit.
7. Suggest `compare-approaches`.

## Notes

- Check **dataset quality** as well as existence. Pull a sample (dataset viewer
  `first-rows` API or `huggingface-datasets`) and check labels against text with
  word-boundary matching, not substring matching. A substring check passes
  mislabelled rows by construction.
- A paper with no released weights is a different finding from no paper. Record both.
- Licence chains matter. Record dataset licences as carefully as model licences.
- Network calls: read-only searches. No Hub or GitHub writes.
