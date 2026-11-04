---
name: setup-unsloth-local
description: Install Unsloth for on-device fine-tuning on a local NVIDIA GPU, after checking the hardware. Use for "set up Unsloth", "train locally".
---

# Set up Unsloth for local training

## Steps

1. Run `../../scripts/paths.sh init`. If `../../scripts/paths.sh override setup-unsloth-local`
   prints a path, read that file and follow it.
2. **Check the hardware first.** Run `nvidia-smi`. With no NVIDIA GPU, stop before
   installing anything and suggest `setup-cloud-training`: the install is several
   gigabytes and can't train without one. Report the GPU, its memory and the driver's CUDA
   version. Unsloth asks for CUDA 12.4 or later, or 12.8 or later on Blackwell cards.
3. Ask where the environment should live, suggesting `~/unsloth_env`. Keep it out of the
   recipes repo.
4. Install, adjusting the path:
   ```bash
   uv venv ~/unsloth_env --python 3.13
   source ~/unsloth_env/bin/activate
   uv pip install unsloth --torch-backend=auto
   ```
5. Check that the GPU is visible from the environment:
   ```bash
   python -c "import unsloth, torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))"
   ```
   This must print `True` and the GPU's name.
6. Write `training_backends.local-unsloth` to `config.json` with `unsloth_env` (the path)
   and `gpu`, keeping every other key.

## Data storage

Writes only `training_backends.local-unsloth` in
`${WORKSPACE:custom-model-planning}/config.json`, plus the environment at the chosen path.

## Notes

Install steps follow https://unsloth.ai/docs/get-started/install-update/pip-install.
For a specific torch and CUDA pairing, that page has an advanced section.
