# Hugging Face Hub search recipes

Verified against the live Hub API and `hf` CLI 1.25.1 on **2026-10-15**. Re-check
the traps section if the results look off. The Hub changes its API without notice.

No token is needed for public search. Set `HF_TOKEN` only to see gated or private
repos.

## Endpoints that work

| Need | Request |
| --- | --- |
| Models for a task, most used first | `GET https://huggingface.co/api/models?pipeline_tag=text-classification&search=<words>&sort=downloads&direction=-1&limit=20` |
| Same, with useful fields | add `&expand[]=downloads&expand[]=likes&expand[]=cardData&expand[]=safetensors&expand[]=lastModified&expand[]=pipeline_tag&expand[]=tags` |
| Models tagged with a language | `&filter=he` (the **bare** ISO code as a tag) |
| Models by licence | `&filter=license:mit` |
| One model in full | `GET https://huggingface.co/api/models/<id>` |
| Model card text | `GET https://huggingface.co/<id>/raw/main/README.md`, or `hf models card <id>` |
| Fine-tunes of a base | `&filter=base_model:<base-id>` (also `base_model:finetune:<id>`, `base_model:adapter:<id>`, `base_model:quantized:<id>`) |
| Datasets | `GET https://huggingface.co/api/datasets?search=<words>&sort=downloads&limit=20` (`filter=` takes tags such as `task_categories:text-classification`, `language:he`) |
| Spaces (demos) | `GET https://huggingface.co/api/spaces?search=<words>&limit=20` |
| Papers | `GET https://huggingface.co/api/papers/search?q=<words>` — returns a JSON list; arXiv IDs in `paper.id` |
| The task list | `GET https://huggingface.co/api/tasks`: 47 pipeline tags on 2026-10-15 |

CLI equivalents: `hf models ls --search … --pipeline-tag … --sort downloads --limit 20 --expand downloads,likes,cardData,safetensors`,
`hf datasets ls --search …`, `hf papers search "<q>"`, `hf papers read <arxiv-id>`.

`expand` replaces the default field set: with it, you get **only** the listed
properties plus `id`. Always include `pipeline_tag` and `tags` if you need them.

## Traps: these fail silently

Each of these returns HTTP 200 with plausible-looking results. Nothing tells you
the filter was ignored.

1. **`language=<code>` is ignored on `/api/models`.** `?language=he&pipeline_tag=token-classification`
   returned an Indonesian POS tagger and English NER models. Use `filter=he`.
2. **`filter=language:he` returns an empty list on `/api/models`**, which reads as
   "no Hebrew models exist". On models, language is a bare tag. (On **datasets**,
   `language:he` is the correct form.)
3. **The `num_parameters` filter does not bound size.** Both
   `?num_parameters=min:0,max:500M` and `hf models ls --num-parameters min:0,max:500M`
   returned 2B–8B models. Read `safetensors.total` per model and filter it yourself.
   GGUF and other non-safetensors repos have no `safetensors` field. Get their
   size from the model card or the base model.
4. **Language tags are inflated by massively multilingual models.** `filter=he`
   ranked by downloads is dominated by models tagged with 100+ languages. Inspect
   `cardData.language` length: a model tagged with 400 languages is not evidence
   of good Hebrew support.
5. **Downloads are popularity, not fitness.** A popular model can be one forked
   by many pipelines. Read the card's eval section and its training data.

## Size buckets

Use `safetensors.total` (parameter count) and bucket it for the user:

| Bucket | Params | Typical fit |
| --- | --- | --- |
| tiny | < 50M | on-device, browser (transformers.js), microcontroller-adjacent |
| small | 50M–400M | CPU server, mobile, encoder classifiers |
| compact | 400M–2B | single consumer GPU, small decoder LLMs |
| mid | 2B–10B | one GPU with quantisation |
| large | > 10B | out of scope for this plugin's focus |

## Search strategy

1. Search by **task** (`pipeline_tag`) first and by **wording** second. Model
   names rarely contain the user's phrasing.
2. Search for **synonyms** of the task in the user's domain. For example, "intent
   detection", "query classification" and "routing" all describe one task.
3. Search **datasets** for the task even when the user only asked about models.
   A good labelled dataset with no model is a strong fine-tune signal.
4. Check **fine-tunes of the obvious bases** (`filter=base_model:<id>`). Niche
   task models often exist as fine-tunes that are not tagged with the task.
5. Search **papers**. A task with papers but no released weights is a different
   finding from a task nobody has studied.
6. Record every query and its result count in `research/`, including the empty ones.
