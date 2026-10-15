---
name: select-base-model
description: Pick a base model to fine-tune: shortlist small open-weights candidates by size, licence, language coverage and task fit, then compare.
---

# Select a base model

For a fine-tune or distillation, choose the base. The newest or most-downloaded
base is not automatically right. Compare candidates explicitly against the
requirements.

Plugin references live at `../../references/` relative to this skill's directory.
Read `hub-search-recipes.md` and `task-taxonomy.md`.

## Inputs

- `docs/requirements.md` (size budget, languages, licence intent, deployment),
  `docs/prior-art.md` and `docs/options.md`.

## Steps

1. Derive **hard filters** from the requirements: max params from the deployment
   target, required languages or scripts, licence compatible with the intended
   release, and architecture compatible with the task head (encoder for
   classification and tagging unless there is a reason otherwise).
2. Build a long-list of 6–12 candidates from the families in `task-taxonomy.md` and
   any bases prior art used successfully. Query the Hub live for each family's
   current members. Sizes come from `safetensors.total` (the `num_parameters`
   filter does not bound size).
3. For each candidate, check and record (confirmed vs inferred):
   - Params and size bucket, plus disk size at fp16 and int8.
   - Licence, read from the card and `cardData.license`. Flag gated or non-commercial.
   - **Tokenizer coverage** of the target language or script. Tokenize 3–5 sample
     inputs from `requirements.md` if `transformers` is available, or reason from
     the tokenizer's training languages otherwise. Excessive fragmentation (many
     tokens per word) is a red flag for small models.
   - Max context length vs expected input length.
   - Evidence on similar tasks: prior-art results using this base.
   - Ecosystem: ONNX / transformers.js / GGUF exports if the deployment needs them.
4. Cut to a **shortlist of 2–3**. Compare them in a table and recommend one, with
   one runner-up kept as a fallback for the eval.
5. Write `docs/base-model.md`: filters, long-list with reasons for each cut,
   shortlist table, recommendation, and `As of <date>`. Record the choice in
   `docs/decisions/NNNN-base-model.md`.
6. Update `project.json` (`stages.base_model`) and the hub registry `base_model`. Commit.
7. Suggest `plan-training-data`.

## Notes

- Plan to evaluate the runner-up as well. "Defaults are not always best": an
  older or smaller base sometimes beats the newest on a narrow task.
- For memory fit, use the `hf-mem` skill if installed. Otherwise estimate
  params × bytes per param × ~1.2 for inference, with training needing ~4× more for
  full fine-tuning and much less for LoRA. Label it as an estimate.
- A multilingual base tagged with 100+ languages may still tokenize the target
  language badly. Test it rather than trusting the tag.
