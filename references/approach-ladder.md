# The approach ladder

When someone wants a custom model, the cheapest rung that meets the requirement wins.
Work up from the bottom. Each rung must be **ruled out with a reason** before the
next one is considered. Most niche ideas end on rungs 0–3, and finding that out is
a good result.

| Rung | Approach | Choose when | Rule out when |
| --- | --- | --- | --- |
| 0 | **No model.** Rules, regex, a lexicon, a lookup table, a heuristic | The decision is mostly enumerable: a closed vocabulary, fixed formats, known keywords | Recall on realistic input falls below the eval bar, or the rule set needs constant growth |
| 1 | **Use an existing model as-is** | The exists check found a model whose task, labels, language and licence match | Labels differ, domain shift degrades it on the eval set, the licence forbids the use, or it is too big |
| 2 | **Prompt a general LLM** (zero- or few-shot, hosted or local) | Low volume, latency-tolerant, the budget allows per-call cost, privacy allows it | Cost × volume is too high, it must run offline or on-device, latency budget is tight, or output is inconsistent |
| 3 | **Embeddings + light head.** A frozen sentence encoder plus logistic regression/kNN, or SetFit | Classification with few labelled examples (8–64 per class), with a small CPU-friendly model | Labels depend on token-level or structural detail embeddings blur |
| 4 | **Fine-tune a small encoder.** BERT-family for sequence or token classification | Classification, NER, span tagging; hundreds to thousands of labels available or affordable | The output must be generated text, or the input is a modality the encoder lacks |
| 5 | **Distil from an LLM.** An LLM labels data, a small model learns it | Rung 2 works but is too expensive or slow at volume; the labelling task is well defined | The LLM's own labels fail the eval bar, because the student cannot beat the teacher |
| 6 | **Fine-tune a small decoder or seq2seq** (full or LoRA/QLoRA) | Generative output: rewriting, extraction into structure, constrained generation | A classifier formulation would do. Generative is the costlier way to classify |
| 7 | **Adapt a speech/vision/multimodal base** (Whisper/Parakeet-class ASR, ViT/CLIP-class vision) | Non-text modality with a domain or language gap | Rungs 0–3 equivalents exist (e.g. off-the-shelf ASR + text post-processing) |
| 8 | **Train from scratch** | A new modality, tokenisation or architecture with no usable base; or the size limit is below anything pretrained | Almost always. Needs a written justification in `docs/decisions/` |

## What to estimate per rung considered

For every rung that survives a first look, write down:

- **Data needed**: how many labelled examples, and whether they exist (link) or must be made.
- **Compute**: rough GPU-hours and the smallest viable hardware. "Free Colab T4",
  "one 24 GB consumer GPU" and "rented A100 for a day" are useful granularity.
- **Inference footprint**: params, quantised size on disk, CPU latency estimate.
- **Licence chain**: base model licence + dataset licences + the intended release
  licence. A permissive release on a non-commercial base is a blocker, not a footnote.
- **Expected quality**: grounded in prior art (a paper or model with numbers on a
  similar task), not intuition. Say so when there is no grounding.
- **Maintenance**: who relabels when the domain drifts.

## The no-model baseline is mandatory

Even when rung 0 is obviously insufficient, build it (or specify it precisely) as the
eval baseline. A fine-tuned model that does not clearly beat a 50-line regex on the
eval set has not earned its place. `plan-evaluation` makes the baseline part of the
pass bar.
