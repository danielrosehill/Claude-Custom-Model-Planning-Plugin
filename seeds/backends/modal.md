# Backend: modal

Serverless GPUs, billed per second. Good default for runs with no local GPU.

- **Needs:** the `modal` CLI, authenticated (`setup-cloud-training`).
- **Wrap the recipe:** add `modal_app.py` to the recipe folder. It defines the image
  from `requirements.txt`, the GPU from `recipe.yaml`, a Volume mounted at the output
  path, and a function that runs `train.py`. Check current syntax at
  https://modal.com/docs before writing it.
- **Launch:** `modal run --detach modal_app.py` for anything longer than a few minutes,
  so it survives the session ending.
- **Watch:** `modal app list`, `modal app logs <app-id>`.
- **Stop:** `modal app stop <app-id>`.
- **Outputs:** write to the Volume, never the container disk, which is lost at exit.
- **After the run:** confirm the app has stopped. Volume contents keep costing storage.
