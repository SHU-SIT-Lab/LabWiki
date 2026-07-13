# Containers with Enroot & Pyxis

The cluster runs GPU workloads in containers rather than installing software
system-wide. **Enroot** is the (unprivileged, rootless) container runtime;
**Pyxis** is the Slurm plugin that lets you launch an Enroot container
directly as part of an `srun`/`sbatch` job, using the `--container-image`
flag.

## Why containers here

- No `sudo`/root needed — Enroot runs as your own user
- Reproducible environments (CUDA/cuDNN/PyTorch versions pinned in the image)
- No conflicts between different people's Python/CUDA setups on shared nodes

## Running a container interactively

Pull straight from a registry (Docker Hub, NGC, GHCR, etc.) using the
`#registry#image:tag` syntax:

```bash
srun --gres=gpu:1 \
     --container-image=nvcr.io#nvidia/pytorch:24.05-py3 \
     --pty bash
```

The first time you use a given image, Pyxis has Enroot import and cache it,
so it may take a minute; subsequent runs reuse the cached image.

## Running a container in a batch job

```bash title="train_container.sbatch"
#!/bin/bash
#SBATCH --job-name=containerized-train
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=logs/%x-%j.out

srun --container-image=nvcr.io#nvidia/pytorch:24.05-py3 \
     --container-mounts=/home/data/scratch/$USER/project:/workspace \
     bash -c "cd /workspace && python train.py"
```

## Useful `--container-*` flags

| Flag | Meaning |
|---|---|
| `--container-image=` | Image to pull/run, e.g. `nvcr.io#nvidia/pytorch:24.05-py3` or a `docker://` reference |
| `--container-mounts=` | Bind-mount host paths into the container, `host:container` |
| `--container-workdir=` | Working directory inside the container |
| `--container-name=` | Name the container instance so it can be reused across steps |
| `--container-writable` | Make the container filesystem writable (otherwise read-only) |
| `--no-container-remap-root` | Disable Pyxis's default root-remap behavior, if you need real root-like UID mapping semantics inside the container |

## Building your own image

*Fill in your lab's preferred workflow — e.g.: build a Docker image locally
or in CI, push to a registry the cluster can reach (Docker Hub / GHCR / a
private registry), then reference it with `--container-image`. Note any
registry credentials/login steps required for private images.*

## Enroot image cache

Store container images and related cache files under `/home/data/containers`.
Keep datasets in `/home/data/datasets`, working files and outputs in
`/home/data/scratch`, and material intended for group use in
`/home/data/shared`.

## Tips

- Keep training code and data **outside** the container (via
  `--container-mounts`) so the image itself stays small and reusable.
- Prefer official NVIDIA NGC images (`nvcr.io/nvidia/...`) for CUDA/PyTorch/
  TensorFlow — they're built and tested for NVIDIA GPUs.
- If a container fails to start, check `sinfo`/node health first — Pyxis
  errors sometimes mask an underlying node problem.
