---
name: standardize-dataset
description: Align a dataset built up over time, and every subset it draws on, to one convention before training from scratch. Works backwards from a run that has to start again anyway: inventory the conventions actually in use, write one standard, record each decision, dry-run, rewrite labels with the old values kept, and enforce the standard at ingest. Use when the user says "standardize the dataset", "align the datasets", "since we're starting from scratch, make everything compatible", "one convention across all the datasets", "clean this up before the retrain".
---

# Retrospective dataset standardization

Datasets drift: conventions change over months, new sources arrive with their own habits, and each one was
reasonable at the time. Incremental training works around that. A from-scratch run is the moment to fix it,
because nothing depends on the old labels any more, so the cost of changing them is at its lowest.

Usually follows a "from scratch" verdict from `evaluate-incremental-training`. The goal is that the next run has
nothing to repair: no per-run conversion, no rows dropped or relabelled every time.

## Rules

- **Never rewrite published data without the user's yes on the dry run.** Show the counts and samples first.
- **Source data is not changed.** Audio, images and raw text stay as they are. Labels and metadata change, and a
  changed row keeps its old value in a `*_before_normalization` field.
- **Count what is actually trained.** The convention most trained rows follow is the default; a rule on paper that
  few rows follow goes to the user with a recommendation.
- **Different things stay different.** A name and a common noun that look alike are not a spelling conflict.
  Deliberate variants are recorded as deliberate, and not merged.

## 1. Inventory

List every constituent dataset, subset and source, with its revision, row count and how it gets into training. Then
measure what each one actually does, per dataset, from the data and not the docs:

- **Schema:** column names, types, required fields, ids, and fields that mean different things in different sets.
- **Labels:** casing, punctuation, number and date format, spelling variants, abbreviations, script, whitespace, and
  characters outside the target tokenizer.
- **Inputs:** format, sample rate, channels, bit depth, resolution, length.
- **Metadata:** speaker or author fields, categories, tags, licence, provenance.
- **Splits:** how train, validation and test were made, and whether they are still disjoint across all datasets taken
  together. Sets that are clean alone can leak into each other.

## 2. Write the standard

One document, in the dataset repo, that a new source can be checked against. For each field: the rule, an example, and
the reason. Choose the output of the target model, not whichever form is easiest to convert: if the model should
write digits, every label uses digits.

Put the open conflicts to the user as one table: the forms, trained-row counts for each, and a recommended pick.
Decide clear errors and cases an existing rule covers without asking.

## 3. Record decisions as data

Keep each decision in a machine-readable file (`from`, `to`, `date`, `why`, matched on word boundaries), so a later
rebuild or re-export cannot undo it. If a term list or upstream source feeds the data, change it there too.

## 4. Dry run, apply, verify

1. Dry run: counts per rule and per dataset, with samples. Read them for wrong rewrites, then show the user.
2. Apply on a machine with room for the data, usually in the cloud. A rewrite of a hosted dataset can move every
   shard. Commit against the expected parent revision, so a concurrent push fails loudly and does not get overwritten.
3. Standardize formats once, at the source, so training stops converting them on every run.
4. Rebuild the splits if the rewrite merged rows or terms. Eval text needs the same standard, so old scores are no longer
   comparable: record the break and the new baseline revision.
5. Re-run the inventory. Decided conflicts should be gone; anything left is a bug in the rule or a new decision.

## 5. Keep it standard

A standard not enforced at ingest drifts again. Add the checks to whatever accepts new rows: validate on write where
possible, otherwise as a conformity check before each training run. Apply the same decisions to the prompts or
generators that make new rows, or they will keep producing the old form.

Then record the final dataset revision for the from-scratch run. Update the dataset card in the same commit as the
conventions.
