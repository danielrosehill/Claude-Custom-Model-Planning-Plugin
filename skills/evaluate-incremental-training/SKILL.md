---
name: evaluate-incremental-training
description: Decide whether a model can be updated incrementally from its last checkpoint on the data added since, or needs training from scratch. Goes beyond counting new data: checks that the new rows are compatible with the parent run (tokenizer, labels, audio or input format, schema, splits, distribution, recipe) and gives one verdict. Read-only, spends nothing. Use when the user says "can this be an incremental train", "evaluate whether we can train incrementally", "is this delta compatible", "continue from the last checkpoint or start again".
---

# Evaluate incremental training

A delta count says how much is new. It does not say whether the new data can safely continue the old
weights. This skill answers that second question, and it runs before any GPU is booked.

Read-only: it changes no data, starts no run and adds no benchmark. Starting a run is the user's call.

## Inputs

- The parent run's record: base model, checkpoint path, tokenizer, dataset revision, preprocessing, data mix,
  held-out set, recipe (learning rate, epochs, batch size, optimizer state kept or fresh).
- The dataset now, at a pinned revision. Compare two revisions, never "latest" against memory.

If the parent's revision or row ids were not recorded, say so: the delta can only be estimated, and that is a
finding in its own right.

## 1. Measure the delta

From metadata where possible, without downloading the data:

- rows and hours added, removed and **changed** (same id, different label);
- growth against the parent's pool, and against the last from-scratch run;
- new vocabulary, classes or terms;
- rows that are new but must not train: eval, test or pending rows.

## 2. Check compatibility

Check each one and report pass, warn or block, with counts. Measure it: a check that returns zero rows on a
dataset that should have some is a broken check, not a pass.

| Check | Measure | Blocks when |
|---|---|---|
| **Tokenizer coverage** | Round-trip every new label through the parent's tokenizer; list characters and pieces that come back as unknown | New labels need symbols the tokenizer cannot write. A fixed vocabulary cannot learn them by continuing |
| **Architecture and framework** | Checkpoint loads in the current training stack; same head, same output classes | The label space or the framework format changed |
| **Label conventions** | Casing, punctuation, number format, spelling and normalization in new rows against parent rows | Conventions changed: the model gets two targets for one input |
| **Changed old labels** | Parent rows whose labels were rewritten | Many rewrites. Warn on a few: replay only teaches the new form if rewritten rows are in the sample |
| **Input format** | Sample rate, channels, bit depth and codec for audio; resolution for images; length distribution | The pipeline cannot convert it, or conversion hides a real change, such as a new narrowband microphone |
| **Schema** | Column names and types, required fields, empty or pending rows | Rows silently drop or a field changes meaning |
| **Split integrity** | No new row, or its held-out terms and speakers, overlaps eval; the validation set is unchanged or the change is noted | Eval leakage. A grown validation set is a warn: scores stop being comparable with the parent's |
| **Distribution shift** | Share of each category, speaker and domain in the delta against the pool | The delta is a new domain or mostly one category, and replay is too thin to protect the rest |
| **Line filters** | Every new category or tag is classified for each model line that excludes some | A new tag would leak into a line that should not see it |
| **Parent availability** | Weights exist where training can read them, and the parent's row list is present for the delta and replay selection | The parent is missing or unverified |
| **Lineage** | Number of chained incremental runs and total growth since the last from-scratch run | Warn only: long chains drift, and the base recipe has not seen the whole pool together |

## 3. Give the verdict

- **Incremental:** nothing blocks. State the recipe: continue from the parent, low learning rate (about a third of
  the from-scratch rate or less), few epochs, fresh optimizer, the new rows plus a replay sample of old rows (a
  ratio around 3:1 old to new, with a floor so a small delta still sees enough replay). Keep the recipe identical
  to the last incremental run unless a finding says otherwise.
- **Incremental after a fix:** a block that a data fix removes, such as a filter or a dropped row type. Name the fix.
- **From scratch:** tokenizer, architecture or label-space blocks, widespread label rewrites, or a domain change replay
  cannot cover. Offer `standardize-dataset` first, because a from-scratch run is the cheapest moment to align
  the dataset.
- **Keep building:** compatible, but the delta is too small to justify a run. Give the amount still needed. Any floor
  is a judgement call, so say so.

Say what was confirmed by measurement and what was inferred. Estimate the run's time and cost from the
last comparable run, not from a rule of thumb.

## Output

One line to the user with the verdict and the reason, then the table of checks that are not a clean pass. In a
project repo, save the full result as JSON beside the run records, with both dataset revisions, so the
next evaluation can compare against it.
