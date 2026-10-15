# From an idea to a task type

Users describe what they want ("flag emails that need a reply", "tell me which
words are Hebrew"). The Hub indexes by **pipeline tag**. Framing converts one into
the other, and choosing the formulation is a real design decision. The same idea
often fits two formulations with very different costs.

## Common formulations

| User says… | Formulation | Pipeline tag | Output |
| --- | --- | --- | --- |
| "Is this X or not?", "which category?", "route this" | Sequence classification (binary / multi-class / multi-label) | `text-classification` | label(s) + score per input |
| "Find the X in this text", "which words are…" | Token classification / span tagging (BIO) | `token-classification` | label per token, merged into spans |
| "How similar / relevant is this?" | Embedding / bi-encoder, or cross-encoder reranker | `sentence-similarity`, `feature-extraction`, `text-ranking` | vector, or score per pair |
| "Pull these fields out into JSON" | Extraction: token classification if fields are spans, seq2seq/decoder if they need normalising | `token-classification` or `text-generation` | structured record |
| "Rewrite / normalise / correct this" | Seq2seq or small decoder | `text2text-generation` (legacy tag), `text-generation` | text |
| "Is this audio X?", "who is speaking?" | Audio classification | `audio-classification` | label |
| "Transcribe my domain/language better" | ASR adaptation | `automatic-speech-recognition` | text |
| "What's in this image / is it X?" | Image classification, detection | `image-classification`, `object-detection` | label / boxes |
| "Classify with labels I'll change later" | Zero-shot classification (NLI-based or embedding-based) | `zero-shot-classification` | score per candidate label |

The full live list: `GET https://huggingface.co/api/tasks` (47 tags on 2026-10-15).

## Formulation questions to settle during framing

1. **Unit of decision.** Per document, per sentence, per token, per pair? This
   picks the head and the labelling cost.
2. **Label set.** Closed and stable, or open and changing? Changing labels favour
   zero-shot or embeddings + head (rungs 2–3) over a fixed classifier.
3. **Multi-label vs multi-class.** Can one input carry two labels? Getting this
   wrong invalidates the dataset.
4. **Abstain option.** Does the model need an "unsure / none of these" output?
   Usually yes for routing.
5. **Precision vs recall.** Which error is worse? This sets the threshold and the
   eval metric, and sometimes the whole design. A conservative detector feeding a
   human review queue is a different model from an autonomous filter.
6. **Input length and language mix.** These limit the base choice: context length,
   tokenizer coverage, script handling.
7. **Where it runs.** Browser, phone, CPU server, GPU, edge device. The size budget
   comes from here, not from preference.

## Base families by formulation (starting points, verify live)

Names here are families to **search for**, not recommendations. Check the Hub for
the current best member, its size (`safetensors.total`) and licence before
shortlisting. As of 2026-10-15:

- **Encoders for classification/tagging:** ModernBERT, DeBERTa-v3, (Distil)RoBERTa,
  XLM-RoBERTa / mDeBERTa for multilingual, language-specific BERTs where they exist.
- **Sentence embeddings:** sentence-transformers models, the BGE / GTE / E5 /
  multilingual-e5 families, static-embedding models for CPU-only.
- **Small decoders:** SmolLM, Qwen small variants, Gemma small variants, Llama 3.2 1B-class.
- **ASR:** Whisper (tiny → large-turbo), NVIDIA Parakeet / Canary, language-specific
  fine-tunes.
- **Vision:** ViT / ConvNeXt / EfficientNet-class backbones, DINOv2 features, CLIP/SigLIP for zero-shot.
