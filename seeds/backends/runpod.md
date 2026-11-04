# Backend: runpod

Rented GPU pods, billed for as long as the pod exists. Good for long runs and for GPUs
that are hard to get elsewhere.

- **Needs:** `runpodctl`, configured with an API key (`setup-cloud-training`).
- **Commands:** subcommands have changed between versions, so read `runpodctl --help`
  on the installed version before creating a pod.
- **Launch:** create a pod with the GPU from `recipe.yaml`, copy the recipe folder in,
  install `requirements.txt`, and run `train.py` inside `tmux` or with `nohup` so it
  survives a dropped connection.
- **Outputs:** copy them off the pod, or write to a network volume, before teardown.
- **After the run:** delete the pod. An idle pod keeps billing, and a stopped pod can
  still bill for its disk. List pods again to confirm it is gone.
