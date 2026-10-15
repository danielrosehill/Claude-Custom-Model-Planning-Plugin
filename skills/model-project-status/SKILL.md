---
name: model-project-status
description: Where is this model project up to? Report stage, verdict and next step for one planning repo, or every project in the hub registry.
---

# Model project status

Reads planning state and says where things stand and what to do next. Use it at the
start of a session on a model project, or to survey every model idea in the hub.

Plugin references live at `../../references/` relative to this skill's directory.

## Inputs

- Current directory (a planning repo), a named project, or "all" for the hub.

## Steps

1. **One project** (the current dir has `project.json`, or a named project resolved
   through the hub registry):
   - Read `project.json`, then **check it against the files**. A stage marked
     `done` whose doc is missing or empty is reported as such. The JSON is a
     pointer, not proof.
   - Report: title, status, verdict, each stage with its date, open questions
     gathered from the docs, and the **single next skill to run** with the reason.
   - If an exists check or prior-art survey is more than ~90 days old, flag it as
     stale, because the Hub moves fast.
2. **All projects** (hub registry): read `projects.json` and output a table of name,
   status, status_date, task and next step. For entries with a `local_path`, read
   that repo's `project.json` and flag disagreements between it and the registry.
   Do not fix them silently. List them and offer to update.
3. If asked to fix drift, update the registry from the per-project `project.json`
   (the more specific source), set `updated`, commit and push the hub.

## Notes

- Read-only unless the user asks to fix drift.
- For released projects, verify Hub links still resolve before reporting them as
  live: `GET https://huggingface.co/api/models/<id>` returns 200.
