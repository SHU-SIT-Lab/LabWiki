# Containers with Enroot and Pyxis

**Run every GPU workload inside a container launched through Slurm.** Request
the GPU and the container in the same `srun` command. Enroot is the rootless
container runtime; Pyxis connects it to Slurm. You do not need `sudo`, Docker
group membership or a Docker daemon on the Spark.

The manager blocks GPU access from ordinary login sessions and personal
services. A container started directly from an SSH shell does not create a GPU
allocation. See [Cluster Changes for Users](cluster-updates.md) for the policy.

## Choose a compatible image

The Sparks use **ARM64 (`aarch64`) CPUs and GB10 GPUs**. An x86-only image or a
framework that lacks GB10 support will not work. The examples pin NVIDIA's
PyTorch **25.09-py3**, which includes CUDA 13.0.1; see the
[NVIDIA release notes](https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/rel-25-09.html).
Pin a version for reproducibility and check compatibility before changing it.

Pyxis accepts a registry image or an existing SquashFS file:

| Image form | Example |
|---|---|
| NVIDIA registry | `nvcr.io#nvidia/pytorch:25.09-py3` |
| Docker Hub | `ubuntu:24.04` (a CPU base image, not a complete GPU ML environment) |
| Exported image file | `"$HOME/containers/my-project.sqsh"` |

Use the `#` separator for a non-default registry with the installed Enroot/Pyxis
stack. The image file and its parent directories must be readable by your user
on the allocated node. A file in your shared home has the same path on all nodes.
The [Pyxis usage guide](https://github.com/NVIDIA/pyxis/wiki/Usage) describes its
image and mount options.

## Interactive and batch commands

The [Slurm guide](slurm-jobs.md) contains complete interactive and batch GPU
container examples. Both bind a project directory into `/workspace`, run as your
ordinary identity, and request CPU, memory and time as well as a GPU.

Keep source, data and outputs in bind-mounted directories. Changes made only
inside a temporary container filesystem may disappear when the job ends.
Container preparation and model downloads count toward the job's time limit.

## Useful options

| Option | Purpose |
|---|---|
| `--container-image=` | Choose the image; required for the GPU workflow |
| `--container-mounts="host:container"` | Make project data visible inside the container |
| `--container-workdir=/workspace` | Set the application's working directory |
| `--no-container-remap-root` | Show your normal UID inside the container; this does not grant host privileges |
| `--container-writable` | Allow changes to the temporary container filesystem |
| `--container-name=` | Reuse a named container on the same node; it is not a cluster-wide image |

Create mount source directories and log directories before submission. Keep
credentials out of job scripts and logs.

## Application dependencies and custom images

Install project dependencies inside the job's container or build them into a
versioned image. Avoid changing the host's Python/CUDA installation. A virtual
environment alone is not a container and does not meet the GPU workflow.

For small Python additions, the [LLM smoke test](llm-smoke-test.md) installs
packages into a project directory inside its container. For a reusable environment,
build an ARM64 image on a machine or CI runner with a suitable container builder,
push it to an accessible registry, and use its pinned tag with Pyxis. Ordinary
Spark accounts do not need host Docker access for this workflow. Ask Josh about
private registry credentials and lab-provided images.

## Container working storage and model caches

Leave `ENROOT_RUNTIME_PATH`, `ENROOT_CACHE_PATH` and `ENROOT_DATA_PATH` at their
system defaults. The workers have private per-user working storage on their own
disks. `/shared` is node-local; its name does not mean that it is an NFS share.
Do not redirect Enroot's working cache/data into your shared home or copy another
user's expanded container directories.

Use your shared home for project files, exported `.sqsh` images and persistent
application data. A Hugging Face or Ollama model cache is application data,
separate from Enroot's working cache. Arrange storage with Josh for large model
collections and datasets: shared-home traffic currently crosses the manager's
Wi-Fi connection. `/home/data` is manager-local unless a project has separately
been provisioned for other nodes.

## Ollama and other GPU servers

Run Ollama **inside a GPU-allocated Slurm container**, for the duration of a job.
Use an ARM64/GB10-compatible image that contains Ollama. A host installation
being present does not mean a personal login-session server is an approved GPU
workflow. The recent GPU change did not remove host software.

If Josh has supplied a compatible image at the path below, this starts a server
inside an allocation. Replace the image path with the actual supplied file:

```bash
mkdir -p "$HOME/ollama-models"
OLLAMA_IMAGE="$HOME/containers/ollama-gb10.sqsh"
if test -r "$OLLAMA_IMAGE"; then
  srun --account=hpc --partition=gpu --nodes=1 --ntasks=1 \
     --gres=gpu:1 --cpus-per-task=4 --mem=32G --time=02:00:00 --mpi=none \
     --container-image="$OLLAMA_IMAGE" --no-container-remap-root \
     --container-mounts="$HOME/ollama-models:/models" \
     env OLLAMA_MODELS=/models OLLAMA_HOST=127.0.0.1:11434 ollama serve
else
  echo "Set OLLAMA_IMAGE to a supplied compatible image" >&2
fi
```

This is a foreground interactive server; closing its allocation stops it. Ask
Josh for connection/tunnelling instructions to the **allocated node**, which may
be a worker. Check for a port conflict with another server before choosing a port.
Use a batch job if the server must survive disconnecting, give it a suitable time
limit, and cancel your job when finished.

Stop and disable an old personal Ollama service only if you previously created
that service and have saved any work it is serving:

```bash
systemctl --user disable --now ollama.service
```

This command acts on your own service. It does not create a Slurm job or a
replacement container server.
