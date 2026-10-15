---
name: plan-training-data
description: Plan training and eval data for a fine-tune or classifier: sources, labelling, synthetic generation, size estimates, splits and licences.
---

# Plan the training data

For small task-bounded models, data is usually the project. This skill plans where
the examples come from, how they get labelled, how many are needed, and how they
are split. It plans the data and does not build it. Labelling and generation hand
off to data tools.

Plugin references live at `../../references/` relative to this skill's directory.
Read `delegation.md`.

## Inputs

- `docs/requirements.md` (labels, I/O contract), `docs/prior-art.md` (existing
  datasets), `docs/options.md` (approach), `docs/base-model.md` if one was chosen.

## Steps

1. **Inventory existing data.** Hub datasets from prior art, the user's own data
   (ask what they have: logs, transcripts, exports), and public corpora. For each,
   record the licence, size, label fit, and whether it may train a model released
   under the intended licence.
2. **Inspect samples** of any candidate dataset (dataset viewer `first-rows` API or
   the `huggingface-datasets` skill). Check labels against text with word-boundary
   or exact-span matching. Note the error rate found. Do not assume a published
   dataset is correctly labelled.
3. **Choose sources** and say how each will be used. Options:
   - existing labelled set
   - user data labelled by hand (`data-annotation`)
   - LLM-labelled user data (distillation)
   - synthetic generation (`synthetic-data`)
   - weak labels from the rung-0 rules
   Mixing sources is normal. Record the share of each.
4. **Estimate volume** per label from the approach and prior-art results, not
   from a rule of thumb alone. Give a minimum viable size and a target size.
5. **Design the splits.**
   - The test set comes from the **real target distribution**, never purely synthetic.
   - Hold out **unseen surface forms** (term-disjoint, user-disjoint or
     source-disjoint) where the model could memorise strings rather than learn the task.
   - Include **hard negatives**: inputs that look positive and are not.
   - Fix the test set before training data generation starts, and record its hash.
6. **Labelling guidelines.** If humans or an LLM will label, write the label
   definitions and boundary rules from `requirements.md` as instructions with
   examples. These become the annotation brief.
7. Write `docs/data-plan.md`: inventory table, sources and shares, volumes, split
   design, labelling guidelines (or a link to them), licence chain, PII handling,
   and open risks. Update `project.json` (`stages.data`). Commit.
8. Suggest `plan-evaluation`.

## Notes

- Synthetic data trains surface patterns well and real-world variation badly.
  Plan to measure the synthetic-to-real gap on the real test set.
- If the user's data contains personal information, the plan must say whether it
  can be published as a dataset, and what to strip first.
- Data that cannot be redistributed can still train a model. Record the
  distinction for the model card.
