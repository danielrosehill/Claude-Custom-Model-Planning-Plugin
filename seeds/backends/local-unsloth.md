# Backend: local-unsloth

On-device fine-tuning with Unsloth. Costs nothing per run, limited by GPU memory.

- **Needs:** an NVIDIA GPU and the environment from `setup-unsloth-local`. The path is
  `unsloth_env` in config `training_backends.local-unsloth`.
- **Launch:** activate the environment and run `train.py` in the recipe folder. Use
  `nohup` or `tmux` for anything longer than a few minutes.
- **Before launching:** check free memory with `nvidia-smi`. If the model does not fit,
  lower the batch size or sequence length, or switch to 4-bit QLoRA, before moving to a
  cloud backend.
- **Outputs:** write under `outputs/` in the recipe folder, which the recipes repo
  ignores, so weights never reach git.
