---
name: capture-model-idea
description: Write down an idea for a custom model, fine-tune or classifier as a short idea note, before deciding whether it earns a repo.
---

# Capture a model idea

The lightest step. The user has an idea ("could a small model detect X?", "I want a
fine-tune that does Y") and it should be on disk before it is lost. Many ideas end
at the exists check, so do not create a repository here.

Plugin references live at `../../references/` relative to this skill's directory.
Read `workspace-layout.md` before writing.

## Inputs

- The idea, in whatever form the user gave it: a sentence, a voice-note
  transcript, a pasted thread.
- Optionally: who or what consumes the model's output, and where it would run.

## Steps

1. Read `${WORKSPACE:custom-model-planning}/config.json` if it exists. That
   resolves to `${CLAUDE_USER_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/claude-plugins}/custom-model-planning/config.json`.
2. Decide where the note goes:
   - `hub_path` is set → `<hub>/ideas/<slug>.md`. Read the hub's `CLAUDE.md`/README
     first. Its conventions override this skill.
   - No hub, but the user is already inside a planning repo → `docs/idea.md` there.
   - Neither → ask once: set up a hub folder, or go straight to `start-model-project`?
     Do not invent a location.
3. Write the note. Quote the user's own words verbatim, then fill these short
   sections, leaving any unknown as an explicit open question rather than a guess:
   - **Problem**: what goes wrong today without this model.
   - **Input → output**: one concrete example pair, even a rough one.
   - **Consumer**: a person, a pipeline step, a device.
   - **Constraints known so far**: languages, where it runs, size or latency, licence intent.
   - **Why not an LLM call or an existing model**: the user's reason, if they gave one.
   - **Open questions**.
   - `Captured: <YYYY-MM-DD>`.
4. If a hub registry (`projects.json`) exists, add an entry with `status: "idea"` and
   `local_path` pointing at the idea note. Leave every other entry untouched.
5. Commit in the hub (or planning repo) with a message naming the idea. Push if the
   repo has a remote.
6. Offer the next step in one line: `model-exists-check` for a quick "does this
   already exist?".

## Data storage

Reads `${WORKSPACE:custom-model-planning}/config.json`. Writes only inside the
user's hub or planning repo. Never writes under the plugin install directory.

## Notes

- Keep the slug short and descriptive: `voice-note-intent-router`, not `idea-3`.
- If the idea is really two models, such as a detector plus a generator, capture it
  as one idea and list the split as an open question. Framing decides later.
