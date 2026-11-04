---
name: setup-cloud-training
description: Install and authenticate the Modal CLI and RunPod CLI for cloud GPU training. Use for "set up Modal", "install runpodctl".
---

# Set up cloud training backends

## Steps

1. Run `../../scripts/paths.sh init`. If `../../scripts/paths.sh override setup-cloud-training`
   prints a path, read that file and follow it.
2. Ask which backends to set up: Modal, RunPod or both. Skip any that already pass the
   check below.
3. **Modal:**
   - Install: `uv tool install modal`. If `uv` is missing, install it first:
     `curl -LsSf https://astral.sh/uv/install.sh | sh`.
   - Authenticate: `modal setup`. This opens a browser, so have the user run it.
   - Check: `modal profile current`, then `modal app list`.
4. **RunPod:**
   - Install to the user's own bin directory, using `arm64` in place of `amd64` on ARM:
     ```bash
     mkdir -p ~/.local/bin && wget --quiet --show-progress https://github.com/runpod/runpodctl/releases/latest/download/runpodctl-linux-amd64 -O ~/.local/bin/runpodctl && chmod +x ~/.local/bin/runpodctl
     ```
   - Authenticate: have the user run `runpodctl doctor`, which prompts for the API key.
     Don't ask for the key in chat.
   - Check: `runpodctl version`, then `runpodctl --help` to see this version's commands.
5. Write each working backend to `training_backends` in `config.json`, for example
   `{"modal": {"status": "ready"}}`, keeping every other key.

## Data storage

Writes only `training_backends` in `${WORKSPACE:custom-model-planning}/config.json`. API
tokens stay in each CLI's own credentials store.

## Notes

The RunPod command is for Linux. On macOS, follow https://docs.runpod.io/runpodctl/install-runpodctl.
These steps install software and don't start anything that bills.
