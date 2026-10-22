---
name: dataset-map
description: Show and keep current the hub's map of shared training datasets, meaning one canonical corpus, the views cut from it, and which projects train on each. Use before planning training data for a project that reuses existing recordings or rows, when adding a new view or consumer, when asked "which datasets do I have for X", "where does this data go", or when several projects might be collecting the same data twice.
---

# Dataset map

When several model projects share source data (recordings, annotated rows), the hub keeps
**one canonical corpus** and defines every other dataset as a **view** of it: a row filter
over the corpus, published as its own dataset. Projects then pick views and transform at
training time (resample, normalise, filter by quality). They never collect the same thing twice
or store a second copy at a different resolution. This skill reads and maintains that map.

Plugin references live at `../../references/` relative to this skill's directory.

## Where the map lives

`datasets.json` at the hub root (`hub_path` in the plugin config), shaped:

```json
{
  "updated": "YYYY-MM-DD",
  "generated_by": "scripts/dataset_map.py",
  "corpus": {"repo": "owner/name", "role": "canonical", "what": "...", "audio": "...", "text": "...",
             "written_by": "...", "views_defined_in": "...", "hub": {"exists": true, "private": false, "gated": false}},
  "views": [{"key": "...", "repo": "owner/name", "rule": "row filter in words", "hub": {...}}],
  "consumers": {"<project name>": ["owner/dataset", "..."]}
}
```

If the hub has a generator script (`generated_by`), the map is **generated**, because the list of
views must come from the code that publishes them. Run it and don't hand-edit. With no
generator, `datasets.json` is hand-maintained.

## Steps

1. **Read.** Load `datasets.json`. If it is missing, say so and offer to create one (ask which
   dataset is canonical; never guess).
2. **Refresh** if it's generated and older than a day, or if the user changed a view: run the
   generator (its docstring has the command). If it has a `--check` mode, run it first and
   report drift.
3. **Verify, don't trust.** `hub.exists: false` from an anonymous call can mean *private* or
   *not created yet*. Views are often created on their first published row. Re-check a missing
   one with a token before calling it broken.
4. **Answer** the question asked:
   - "What do I have for X": the matching views, their rule, and whether each exists yet.
   - "Plan data for project P": the views P could reuse, and what P would have to collect that no
     view covers. Hand the gap to `plan-training-data`.
   - "Add view / consumer": change the source of truth (the publishing code for a view, the
     generator's consumer table or `projects.json` for a consumer), regenerate, then commit
     and push the hub.
5. Keep `projects.json` `hf.datasets` and the map's `consumers` in step, and report any
   disagreement between them.

## Rules

- Prefer a new view over a new collection, and a transform at training time over a second
  stored copy.
- The canonical corpus keeps the highest-fidelity form of the data. Downsampling and
  normalisation belong in training scripts.
- Read-only unless the user asks for a change.
